# Container System - Usage Examples

Diese Beispiele zeigen, wie das neue Container-System in deinen eigenen Node-Skripten verwendet wird.

## 1. Main Menu laden (versteckt Level & HUD)

```gdscript
func load_main_menu() -> void:
    SceneManager.load_into_container(
        SceneRegistry.main_scenes["StartScreen"],
        SceneManager.ContainerType.MENU,
        [SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
        "fade_to_black"
    )
```

## 2. Level starten (versteckt Menu, zeigt HUD)

```gdscript
func start_game_level() -> void:
    # Zuerst Level laden
    SceneManager.load_into_container(
        SceneRegistry.levels["game_start"],
        SceneManager.ContainerType.LEVEL,
        [SceneManager.ContainerType.MENU],  # Menu verstecken
        "fade_to_black"
    )
    
    # Dann HUD laden (ohne Transition)
    await SceneManager.load_complete
    SceneManager.load_into_container(
        "res://Scenes/UI/GameHUD.tscn",  # Beispiel-Pfad
        SceneManager.ContainerType.HUD,
        [],  # Nichts verstecken
        "no_transition"
    )
```

## 3. Settings Menu öffnen (alles bleibt sichtbar)

```gdscript
func open_settings_overlay() -> void:
    SceneManager.load_into_container(
        "res://Scenes/Menus/settings_menu.tscn",
        SceneManager.ContainerType.MENU,
        [],  # Nichts verstecken - Settings als Overlay
        "fade_to_black"
    )
```

## 4. Cutscene spielen (nur Level sichtbar, HUD versteckt)

```gdscript
func play_cutscene() -> void:
    SceneManager.load_into_container(
        "res://Scenes/Cutscenes/Intro.tscn",
        SceneManager.ContainerType.LEVEL,
        [SceneManager.ContainerType.HUD],  # HUD verstecken
        "fade_to_black"
    )
```

## 5. Level wechseln (HUD bleibt geladen)

```gdscript
func change_level(level_path: String) -> void:
    SceneManager.load_into_container(
        level_path,
        SceneManager.ContainerType.LEVEL,
        [],  # Nichts verstecken - HUD bleibt sichtbar
        "fade_to_black"
    )
```

## 6. Direkte Container-Verwaltung

```gdscript
func show_hide_containers_manually() -> void:
    # Direkte Sichtbarkeit über Main Scene
    var main = get_node("/root/Main") as Main
    if main:
        main.level_container.visible = true
        main.hud_container.visible = false
        main.menu_container.visible = true
```

## Container-Typen

- `SceneManager.ContainerType.LEVEL` - Gameplay-Level
- `SceneManager.ContainerType.HUD` - UI/HUD-Elemente
- `SceneManager.ContainerType.MENU` - Menüs und Overlays

## Siehe auch

- [CONTAINER_ARCHITECTURE.md](CONTAINER_ARCHITECTURE.md) - Vollständige Architektur-Dokumentation
- `Autoloads/SceneManager.gd` - SceneManager-Implementierung
- `Scenes/Main/Main.gd` - Container-Setup
