# GAME STATE SYSTEM

## Übersicht

Das Game State System verwaltet den aktuellen Zustand des Spiels und steuert automatisch Pause/Resume-Verhalten.

## Game States

```gdscript
enum GameState {
    MAIN_MENU,      # Game ist geöffnet aber nicht gespielt (in Menus)
    PLAYING,        # Game wird aktiv gespielt
    PAUSED,         # Game pausiert (Settings, Cutscene, etc.)
    TRANSITION      # Level-Übergang läuft
}
```

## Spielablauf

```
Game.exe Start
    ↓
Main Scene lädt (Container-System initialisiert)
    ↓
TRANSITION (Boot Sequence startet)
    ↓
Loading Screen erscheint (in TransitionContainer)
    ↓
MAIN_MENU (Start Screen wird ins MenuContainer geladen)
    ↓ [Player wählt "New Game" oder "Load Game"]
TRANSITION (Level wird geladen)
    ↓
PLAYING (Gameplay läuft)
    ↓ [ESC-Taste / Settings]
PAUSED (Settings Menu geöffnet)
    ↓ [Settings schließen]
PLAYING (Gameplay läuft weiter)
    ↓ [Cutscene startet]
PAUSED (Cutscene läuft)
    ↓ [Cutscene endet]
PLAYING (Gameplay läuft weiter)
    ↓ [Level-Wechsel]
TRANSITION (Neues Level wird geladen)
    ↓
PLAYING (Neues Level aktiv)
    ↓ [ESC-Taste]
TRANSITION (Zurück zum Main Menu)
    ↓
MAIN_MENU (Start Screen)
```

## Verwendung

### State Abfragen
```gdscript
# Aktuellen State prüfen
if Globals.current_game_state == Globals.GameState.PLAYING:
    # Gameplay-Logik

# Auf State-Änderungen reagieren
func _ready():
    Globals.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(old_state:Globals.GameState, new_state:Globals.GameState):
    print("State changed: %s -> %s" % [old_state, new_state])
```

### State Ändern
```gdscript
# Manuell State setzen
Globals.set_game_state(Globals.GameState.PLAYING)

# Convenience-Methoden
Globals.pause_game()    # PLAYING -> PAUSED
Globals.resume_game()   # PAUSED -> PLAYING
```

### Automatisches Verhalten

**Bei State-Wechsel:**
- `MAIN_MENU`: `get_tree().paused = false`
- `PLAYING`: `get_tree().paused = false`
- `PAUSED`: `get_tree().paused = true`
- `TRANSITION`: Kein Auto-Pause (SceneManager steuert das)

### Integration mit Systemen

**Settings Menu:**
- Öffnen: Speichert vorherigen State, setzt `PAUSED`
- Schließen: Stellt vorherigen State wieder her

**Scene Loading:**
```gdscript
# Level starten
Globals.set_game_state(Globals.GameState.TRANSITION)
SceneManager.load_into_container(
    level_path,
    SceneManager.ContainerType.LEVEL,
    [SceneManager.ContainerType.MENU],
    "fade_to_black"
)
await SceneManager.load_complete
Globals.set_game_state(Globals.GameState.PLAYING)
```

**Main Menu Rückkehr (ESC):**
```gdscript
# Automatisch via Globals.return_to_main_menu()
# PLAYING/PAUSED -> TRANSITION -> MAIN_MENU
```

## Beispiele

### Cutscene abspielen
```gdscript
func play_cutscene():
    Globals.pause_game()  # PLAYING -> PAUSED
    
    SceneManager.load_into_container(
        "res://Scenes/Cutscenes/Intro.tscn",
        SceneManager.ContainerType.LEVEL,
        [SceneManager.ContainerType.HUD],
        "fade_to_black"
    )
    
    # Wenn Cutscene fertig
    await cutscene_finished
    Globals.resume_game()  # PAUSED -> PLAYING
```

### Level-Wechsel
```gdscript
func change_level(level_path:String):
    Globals.set_game_state(Globals.GameState.TRANSITION)
    
    SceneManager.load_into_container(
        level_path,
        SceneManager.ContainerType.LEVEL,
        [],
        "fade_to_black"
    )
    
    await SceneManager.load_complete
    Globals.set_game_state(Globals.GameState.PLAYING)
```

### Neues Spiel starten (vom Main Menu)
```gdscript
func start_new_game():
    # Current state: MAIN_MENU
    Globals.set_game_state(Globals.GameState.TRANSITION)
    
    # Level laden
    SceneManager.load_into_container(
        SceneRegistry.levels["game_start"],
        SceneManager.ContainerType.LEVEL,
        [SceneManager.ContainerType.MENU],
        "fade_to_black"
    )
    
    # HUD laden
    await SceneManager.load_complete
    SceneManager.load_into_container(
        "res://Scenes/UI/GameHUD.tscn",
        SceneManager.ContainerType.HUD,
        [],
        "no_transition"
    )
    
    await SceneManager.load_complete
    Globals.set_game_state(Globals.GameState.PLAYING)
```

## Signals

```gdscript
signal game_state_changed(old_state:GameState, new_state:GameState)
```

Wird ausgelöst wenn sich der Game State ändert. Nutze dieses Signal um auf State-Wechsel zu reagieren ohne direkt in Globals eingreifen zu müssen.

## Best Practices

1. **Immer State setzen bei wichtigen Übergängen** (Level laden, Cutscenes, etc.)
2. **State vor Container-Wechseln setzen** für saubere Übergänge
3. **Signal verwenden** statt direktes State-Polling wo möglich
4. **Pause/Resume-Methoden nutzen** statt manuell State zu setzen
5. **TRANSITION State** für alle Lade-Vorgänge verwenden

## Migration vom alten System

Das alte `GLOBAL_STATE` Enum ist deprecated. Neue Projekte sollten `GameState` verwenden:

**Alt:**
```gdscript
# Deprecated
enum GLOBAL_STATE {
    MAIN_MENU,
    GAMEPLAY,
    CONVERSATION,
    PAUSED
}
```

**Neu:**
```gdscript
Globals.GameState.MAIN_MENU
Globals.GameState.PLAYING
Globals.GameState.PAUSED
Globals.GameState.TRANSITION
```
