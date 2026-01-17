# CONTAINER SYSTEM ARCHITECTURE

## Übersicht

Das Projekt nutzt jetzt eine **persistente Main Scene** mit Container-basierter Architektur anstelle vollständiger Scene-Wechsel.

### Scene-Hierarchie

```
Main.tscn (persistente Root)
├── Player (Node2D) - Persistent, invisible for card games
│   └── Camera2D (omnipräsent)
├── LevelContainer (Node2D) - Swap game levels here
├── HudContainer (CanvasLayer) - Swap UI/HUD here
├── MenuContainer (Control) - Swap menus here
└── TransitionContainer (CanvasLayer, layer=100) - Loading screens appear here
```

## Vorteile

- **Player & Camera bleiben persistent** - Kein Neuinitialisieren zwischen Levels
- **Granulare Kontrolle** - Lade nur was sich ändert (Level, UI, oder Menu)
- **Flexible Sichtbarkeit** - Zeige/verstecke Container je nach Game State
- **Dedizierter TransitionContainer** - Loading Screens immer an der richtigen Stelle (Layer 100)
- **Weniger Overhead** - Keine vollständigen Scene-Wechsel mehr nötig

## Boot Sequence

Beim Start der Executable läuft folgende Sequenz ab:

1. **Game.exe startet** → Main.tscn wird geladen
2. **Main._ready()** → Container-System initialisiert, alle Container versteckt
3. **Boot Sequence startet** → SceneManager lädt StartScreen ins MenuContainer
4. **Loading Screen erscheint** → Im TransitionContainer (Layer 100)
5. **Transition abgeschlossen** → StartScreen (Main Menu) ist sichtbar im MenuContainer
6. **GameState → MAIN_MENU** → Spiel bereit für User-Input

Die erste Transition zeigt einen Loading Screen, auch wenn das Laden schnell geht - dies gibt dem Spiel einen professionellen Start-Flow.

## Verwendung

### Level laden (Menu verstecken)
```gdscript
SceneManager.load_into_container(
    SceneRegistry.levels["level_01"],
    SceneManager.ContainerType.LEVEL,
    [SceneManager.ContainerType.MENU],  # Menu verstecken
    "fade_to_black"
)
```

### Main Menu laden (Level & HUD verstecken)
```gdscript
SceneManager.load_into_container(
    SceneRegistry.main_scenes["StartScreen"],
    SceneManager.ContainerType.MENU,
    [SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
    "fade_to_black"
)
```

### Settings Menu als Overlay (nichts verstecken)
```gdscript
SceneManager.load_into_container(
    "res://Menus/settings_menu.tscn",
    SceneManager.ContainerType.MENU,
    [],  # Nichts verstecken
    "fade_to_black"
)
```

## Shortcuts

- **ESC-Taste** - Ruft `Globals.return_to_main_menu()` auf → Lädt StartScreen in MenuContainer

## Migration vom alten System

**Alt (vollständiger Scene-Wechsel):**
```gdscript
SceneManager.swap_scenes(
    scene_path,
    get_tree().root,
    current_scene,
    "fade_to_black"
)
```

**Neu (Container-basiert):**
```gdscript
SceneManager.load_into_container(
    scene_path,
    SceneManager.ContainerType.LEVEL,  # oder HUD, MENU
    [ContainerType.MENU],  # Container zum Verstecken
    "fade_to_black"
)
```

## Wichtige Dateien

- [Main.tscn](Scenes/Main/Main.tscn) - Persistente Root Scene
- [Main.gd](Scenes/Main/Main.gd) - Registriert Container beim SceneManager
- [Player.tscn](Scenes/Player/Player.tscn) - Player mit Camera2D
- [SceneManager.gd](Autoloads/SceneManager.gd) - `load_into_container()` Methode
- [Globals.gd](Autoloads/Globals.gd) - ESC-Taste Handler für Main Menu

## Ordnerstruktur

```
res/
├── Scenes/
│   ├── Main/          (Main.tscn, Main.gd)
│   ├── Player/        (Player.tscn, Player.gd)
│   ├── Levels/        (Alle Level-Scenes)
│   ├── Menus/         (Start, Settings, Loading Screens)
│   └── UI/            (HUD, Game UI Komponenten)
├── Autoloads/         (Globals, SceneManager)
├── Resources/         (SaveData, UserPrefs, SceneRegistry)
└── addons/            (Plugins)
```
