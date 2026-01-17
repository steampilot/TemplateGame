# Godot Game Template - AI Coding Instructions

**Der User heißt Jérôme.**

**Dein Name ist Celestine.**
Du bist eine Expertin für **Godot 4.5 Game Development** und **GDScript**.

## Project Overview
This is a **Godot 4.5 game template** (GL Compatibility renderer) providing reusable systems for menus, scene management, save data, and settings. The template is designed to be forked and customized for new game projects.

### Current Project: Solitär Card Game
**Learning Project** - Developing a Solitaire card game to learn and practice:
- Drag & Drop mechanics
- Menu system integration
- GUI/UI/UX design patterns
- SceneManager workflow
- Save system for scores/statistics

**Using from Template:**
- Start Screen (Main Menu)
- Settings Menu (Audio, preferences)
- SceneManager (scene transitions)
- Save System (highscores, game statistics)

**Building New:**
- Card System (drag & drop, snap-to-position)
- Game Board (Tableau, Foundation, Stock, Waste piles)
- Solitaire game logic (legal moves, win conditions)
- UI Elements (score, timer, move counter, undo)

## Architecture

### Container-Based System (NEW)
The project uses a **persistent Main scene** with container-based architecture instead of full scene transitions.

**Main Scene Structure:**
```
Main.tscn (always loaded)
├── Player (Node2D) - Persistent, invisible for card games
│   └── Camera2D - Omnipresent camera
├── LevelContainer (Node2D) - Swap game levels here
├── HudContainer (CanvasLayer) - Swap UI/HUD here
├── MenuContainer (Control) - Swap menus here
└── TransitionContainer (CanvasLayer, layer=100) - Loading screens appear here
```

**Benefits:**
- Player & Camera persist across all scenes - no re-initialization
- Granular control - only load/unload what changes
- Flexible visibility - show/hide containers based on game state
- Loading screens always render on top (layer 100)

**Container Loading (PREFERRED METHOD):**
```gdscript
# Load level, hide menu
SceneManager.load_into_container(
    SceneRegistry.levels["game_start"],
    SceneManager.ContainerType.LEVEL,
    [SceneManager.ContainerType.MENU],  # Hide these containers
    "fade_to_black"
)

# Load main menu, hide level & HUD
SceneManager.load_into_container(
    SceneRegistry.main_scenes["StartScreen"],
    SceneManager.ContainerType.MENU,
    [SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
    "fade_to_black"
)

# Settings menu as overlay (nothing hidden)
SceneManager.load_into_container(
    "res://Scenes/Menus/settings_menu.tscn",
    SceneManager.ContainerType.MENU,
    [],  # Don't hide anything
    "fade_to_black"
)
```

**Legacy Scene Transitions:**
The old `swap_scenes()` method still exists for backwards compatibility but is not recommended for new code.

### Folder Structure
```
res/
├── Scenes/
│   ├── Main/          - Main.tscn, Main.gd (root persistent scene)
│   ├── Player/        - Player.tscn, Player.gd (persistent player)
│   ├── Levels/        - All gameplay level scenes
│   ├── Menus/         - Start screen, settings, loading screens
│   └── UI/            - HUD components, game UI
├── Autoloads/         - Globals.gd, SceneManager.gd (singletons)
├── Resources/         - SaveData, UserPrefs, SceneRegistry
└── addons/            - Third-party plugins (Todo_Manager)
```

### Autoload Singletons (Global Access)
Two autoload scripts provide game-wide functionality:
- **Globals** ([Autoloads/Globals.gd](Autoloads/Globals.gd)) - Central hub for user preferences, save data, audio bus management, settings menu access, global state enum, and ESC key handler for returning to main menu
- **SceneManager** ([Autoloads/SceneManager.gd](Autoloads/SceneManager.gd)) - Container loading system, legacy scene transitions, loading progress, and data handoff between scenes

Access autoloads anywhere: `Globals.user_prefs.music_volume` or `SceneManager.load_into_container(...)`

### Scene Loading Pattern
**ALWAYS use SceneManager.load_into_container() for scene management** in the container-based architecture.

```gdscript
# Container-based loading (RECOMMENDED)
SceneManager.load_into_container(
    scene_path,
    SceneManager.ContainerType.LEVEL,  # or HUD, MENU
    [SceneManager.ContainerType.MENU], # Containers to hide
    "fade_to_black"                    # Transition animation
)

# Legacy full scene transition (backwards compatibility only)
SceneManager.swap_scenes(
    SceneRegistry.levels["game_start"],
    get_tree().root,
    self,
    "wipe_to_right"
)

# Zelda-style sliding transition (legacy)
SceneManager.swap_scenes_zelda(scene_path, load_into, scene_to_unload, Vector2.RIGHT)
```

**Scene paths go through SceneRegistry** ([Resources/SceneRegistry.gd](Resources/SceneRegistry.gd)) - a centralized dictionary to avoid hardcoded strings. Add new scenes here first.

### Save System Architecture
Two separate persistence systems for different data types:

**User Preferences** - Settings that persist across all saves (audio, graphics, input)
- Class: `UserPrefs` extends `Resource` ([Resources/user_prefs.gd](Resources/user_prefs.gd))
- Location: `user://user_prefs.tres` (binary Godot resource file)
- Access: `Globals.user_prefs.property_name`
- Auto-saves when settings menu closes via `NOTIFICATION_EXIT_TREE`

**Game Save Data** - Player progress, level completion, gameplay state
- Base class: `JSONLoader` ([Resources/json_loader.gd](Resources/json_loader.gd)) - generic JSON read/write
- Game-specific: `SaveData extends JSONLoader` ([Resources/save_data.gd](Resources/save_data.gd)) - add validation and game logic here
- Location: `user://user_save.json` with `res://Resources/default_save_file.json` as template
- Access: `Globals.save.read_level_progress(level_id)`

**When adding new saved data:**
1. Add property to `UserPrefs` for settings OR add to `default_save_file.json` + helper methods in `SaveData` for gameplay data
2. Never save sensitive data directly - add validation in `SaveData` methods

### Settings Menu Pattern
Settings menu pauses the game automatically via `NOTIFICATION_ENTER_TREE`/`EXIT_TREE` notifications.

```gdscript
func _notification(what):
    match what:
        NOTIFICATION_ENTER_TREE:
            get_tree().paused = true
        NOTIFICATION_EXIT_TREE:
            user_prefs.save()
            get_tree().paused = true
```

Open settings from anywhere: `Globals.open_settings_menu()` (currently loads from Globals as preloaded scene)

### Main Scene Registration
The persistent Main scene must register itself with SceneManager on `_ready()`:

```gdscript
# In Main.gd
func _ready() -> void:
    SceneManager.register_main(self)
```

This gives SceneManager access to all containers (Level, HUD, Menu, Transition).

### Loading Screen Integration
Loading screens automatically appear in the **TransitionContainer** (CanvasLayer 100), ensuring they're always on top of all game content. If Main scene is not registered, loading screens fall back to root (legacy behavior).

SceneManager signals for custom behavior:

```gdscript
SceneManager.load_start.connect(_on_load_start)
SceneManager.scene_added.connect(_on_scene_added) 
SceneManager.load_complete.connect(_on_load_complete)

func _on_load_start(_loading_screen):
    # Called when loading begins and loading screen appears in TransitionContainer
```

Progress bar only shows if loading takes >1 second (controlled by Timer in LoadingScreen)

## Code Conventions

### Class Naming & Structure
- All scenes with logic MUST use `class_name` declaration for type safety: `class_name StartScreen extends Control`
- Autoloads don't need `class_name` (accessed via singleton name)
- Use `@onready` for node references: `@onready var music_slider:HSlider = %MusicSlider as HSlider`
- Use unique name `%NodeName` for reliable node references in templates

### Audio Management
Audio buses (Music/SFX) configured in [default_bus_layout.tres](default_bus_layout.tres). Access via:
```gdscript
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)
```

### Error Handling
Use `assert()` for development checks, `push_error()` for runtime validation:
```gdscript
assert(!SceneRegistry.levels.has(level_id), "Level with id %s does not exist." % level_id)
if !LEVEL_STATUS.has(value):
    push_error("%s is an unrecognized value. Save aborted." % value)
    return
```

### Comments & Documentation
Use `## Doc comments` for public APIs and `# Regular comments` for implementation details. See [SceneManager.gd](Autoloads/SceneManager.gd) for documentation standards.

## Development Workflow

### Project Configuration
- Target: Godot 4.5+ (4.2.1 originally, now 4.5)
- Resolution: 640×360 (16:9), optimized for pixel art with integer scaling (see [PIXELART_RESOLUTION_GUIDE.md](Documentation/PIXELART_RESOLUTION_GUIDE.md))
- Window: Non-resizable by default, always-on-top enabled
- Main scene: [Scenes/Main/Main.tscn](Scenes/Main/Main.tscn) - Persistent root with containers
- Start screen: [Scenes/Menus/start_screen.tscn](Scenes/Menus/start_screen.tscn) - Loads into MenuContainer
- Texture filter: Nearest neighbor (pixel art)

### Adding New Features
This is a **template project** meant to be forked. When adding features:
1. Keep code accessible to beginner developers (project goal per CONTRIBUTING.md)
2. Use signals for decoupling rather than tight dependencies
3. Comment non-obvious logic thoroughly
4. Add TODO comments for future improvements (enabled Todo_Manager addon shows these)

### Known Limitations
- SceneManager doesn't support concurrent loading (only one scene at a time)
- Check `SceneManager._loading_in_progress` if rapid scene changes possible
- Zelda transitions assume uniform level sizes (LEVEL_H=360, LEVEL_W=640) - legacy feature
- Container visibility is binary (visible/hidden) - no partial transparency control
- No localization system yet (planned, language dropdown exists but not wired)

## Quick Reference

**Return to main menu:** Press `ESC` key or call `Globals.return_to_main_menu()`  
**Open settings:** `Globals.open_settings_menu()`  
**Load into container:** `SceneManager.load_into_container(path, container_type, hide_containers, transition)`  
**Legacy scene change:** `SceneManager.swap_scenes(path, load_into, unload, transition)` (not recommended)  
**Access saves:** `Globals.save.method_name()` or `Globals.user_prefs.property`  
**Add new scene:** Update `SceneRegistry` constants first  
**Audio volume:** `Globals.user_prefs.music_volume` (0.0-1.0 range)

## Container Types

```gdscript
SceneManager.ContainerType.LEVEL  # Load gameplay levels here
SceneManager.ContainerType.HUD    # Load UI/HUD elements here
SceneManager.ContainerType.MENU   # Load menus here
```

**Example Usage:**
See [CONTAINER_USAGE_EXAMPLES.gd](CONTAINER_USAGE_EXAMPLES.gd) for detailed examples of:
- Loading main menu
- Starting game levels
- Opening settings overlays
- Playing cutscenes
- Level transitions with persistent HUD

For complete architecture documentation, see [Documentation/CONTAINER_ARCHITECTURE.md](Documentation/CONTAINER_ARCHITECTURE.md)
**Audio volume:** `Globals.user_prefs.music_volume` (0.0-1.0 range)
