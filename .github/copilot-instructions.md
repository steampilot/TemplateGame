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

### Autoload Singletons (Global Access)
Two autoload scripts provide game-wide functionality:
- **Globals** ([Autoloads/Globals.gd](Autoloads/Globals.gd)) - Central hub for user preferences, save data, audio bus management, settings menu access, and global state enum
- **SceneManager** ([Autoloads/SceneManager.gd](Autoloads/SceneManager.gd)) - Handles all scene transitions, loading progress, and data handoff between scenes

Access autoloads anywhere: `Globals.user_prefs.music_volume` or `SceneManager.swap_scenes(...)`

### Scene Loading Pattern
**ALWAYS use SceneManager for major scene transitions**, never call `get_tree().change_scene_to_file()` directly.

```gdscript
# Standard scene transition with loading screen
SceneManager.swap_scenes(
    SceneRegistry.levels["game_start"],  # Scene path from registry
    get_tree().root,                     # Where to load (default: root)
    self,                                # Scene to unload (can be null)
    "wipe_to_right"                      # Transition animation name
)

# Zelda-style sliding transition (no loading screen)
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

### Loading Screen Integration
Loading screens are managed by SceneManager but can be repositioned via signals:

```gdscript
SceneManager.load_start.connect(_on_load_start)
SceneManager.scene_added.connect(_on_scene_added) 
SceneManager.load_complete.connect(_on_load_complete)

func _on_load_start(_loading_screen):
    # Reposition loading screen in SceneTree if needed
    _loading_screen.reparent(self)
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
- Resolution: 960×540 (16:9), non-resizable by default, always-on-top enabled
- Main scene: [Menus/start_screen.tscn](Menus/start_screen.tscn)
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
- Zelda transitions assume uniform level sizes (LEVEL_H=960, LEVEL_W=540)
- No localization system yet (planned, language dropdown exists but not wired)

## Quick Reference

**Open settings:** `Globals.open_settings_menu()`  
**Change scene:** `SceneManager.swap_scenes(path, load_into, unload, transition)`  
**Access saves:** `Globals.save.method_name()` or `Globals.user_prefs.property`  
**Add new scene:** Update `SceneRegistry` constants first  
**Audio volume:** `Globals.user_prefs.music_volume` (0.0-1.0 range)
