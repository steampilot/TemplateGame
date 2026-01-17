extends Node

## Game State Management
enum GameState {
	MAIN_MENU,      ## Game is open but not playing (in menus)
	PLAYING,        ## Game is actively being played
	PAUSED,         ## Game paused (settings menu, cutscene, etc.)
	TRANSITION      ## Level transition in progress
}

var current_game_state:GameState = GameState.MAIN_MENU:
	set(value):
		if current_game_state != value:
			var old_state = current_game_state
			current_game_state = value
			game_state_changed.emit(old_state, current_game_state)
			_handle_state_change(old_state, current_game_state)

signal game_state_changed(old_state:GameState, new_state:GameState)

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs
var save:SaveData
#var user_save:UserSave

# temp - I'm not wild about preloads, but this menu is fairly light (to revise in a future version)
var settings_menu_scene:PackedScene = preload("res://Scenes/Menus/settings_menu.tscn")
var settings_menu = null

var _returning_to_main_menu:bool = false
 
func _ready():
	user_prefs = UserPrefs.load_or_create()
	
	# SaveData extends JSONLoader to add methods to read and write data specifically for this game
	# customize SaveData to fit your game. What's in this repo is just a very basic example.
	save = SaveData.new()
	save.load_or_create()
	
	# todo - will implement Resource saver option in future versions
	#user_save = UserSave.load_or_create() as UserSave
	#user_save.save()
	
	# temp - Will probably relocate to an audio-specfiic class in future versions
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(user_prefs.sfx_volume))
	AudioServer.set_bus_mute(SFX_BUS_ID, user_prefs.sfx_volume < .05)
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(user_prefs.music_volume))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, user_prefs.music_volume < .05)
	
	# Don't set state here - Main.gd will handle initial boot sequence
	# State will be set to MAIN_MENU after boot completes

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("MAIN_MENU"):
		return_to_main_menu()

## Internal - handles automatic behavior when game state changes
func _handle_state_change(old_state:GameState, new_state:GameState) -> void:
	match new_state:
		GameState.MAIN_MENU:
			get_tree().paused = false
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.TRANSITION:
			# Don't pause during transitions - let SceneManager handle it
			pass
	
	print("Game State: %s -> %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])

## Set game state with automatic pause handling
func set_game_state(state:GameState) -> void:
	current_game_state = state

## Pause the game (for settings menu, cutscenes, etc.)
func pause_game() -> void:
	if current_game_state == GameState.PLAYING:
		set_game_state(GameState.PAUSED)

## Resume the game
func resume_game() -> void:
	if current_game_state == GameState.PAUSED:
		set_game_state(GameState.PLAYING)

enum GLOBAL_STATE {
	MAIN_MENU,
	GAMEPLAY,
	CONVERSATION,
	PAUSED
}

## DEPRECATED - Use GameState enum instead
## Left for backwards compatibility
const LANGUAGES:Dictionary = {
	0:"en-US",
	1:"es-LAT"
}

func get_selected_language() -> String:
	var s:String = LANGUAGES[user_prefs.language]
	if s:
		return s
	return LANGUAGES[0]

# temp - maybe the settings menu doesn't need to live in a global spot? (will decide in future version)
func open_settings_menu():
	if not settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		get_tree().root.add_child(settings_menu)
	else:
		push_warning('settings menu already exists in this scene')

## Returns to main menu from anywhere in the game
## Loads StartScreen into MenuContainer and hides Level/HUD
func return_to_main_menu() -> void:
	# Prevent multiple calls during transition
	if _returning_to_main_menu:
		return
	
	_returning_to_main_menu = true
	
	# Set state to transition
	set_game_state(GameState.TRANSITION)
	
	# Use new container-based loading system
	# Load main menu into MENU container, hide LEVEL and HUD
	SceneManager.load_into_container(
		SceneRegistry.main_scenes["StartScreen"],
		SceneManager.ContainerType.MENU,
		[SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
		"fade_to_black"
	)
	
	# Wait for transition to complete, then set to main menu state
	await SceneManager.load_complete
	set_game_state(GameState.MAIN_MENU)
	
	# Reset flag after short delay
	await get_tree().create_timer(0.5).timeout
	_returning_to_main_menu = false
