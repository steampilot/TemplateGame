class_name Main extends Node

## Main persistent scene that holds all game containers
## This scene stays loaded throughout the entire game session
## Containers are used to swap out levels, UI, and menus without full scene transitions

@onready var player:Player = $Player
@onready var level_container:Node2D = $LevelContainer
@onready var hud_container:CanvasLayer = $HudContainer
@onready var menu_container:Control = $MenuContainer
@onready var transition_container:CanvasLayer = $TransitionContainer

var _boot_complete:bool = false

func _ready() -> void:
	# Register this Main instance with SceneManager
	SceneManager.register_main(self)
	
	# Start initial boot sequence
	_start_boot_sequence()

## Initial boot sequence when game starts
## Shows loading screen, then loads main menu splash screen
func _start_boot_sequence() -> void:
	if _boot_complete:
		return
	
	print("=== BOOT SEQUENCE START ===")
	
	# Hide all containers initially
	level_container.visible = false
	hud_container.visible = false
	menu_container.visible = false
	
	# Small delay to ensure everything is initialized
	await get_tree().create_timer(0.1).timeout
	
	# Load main menu into MenuContainer
	print("Loading Main Menu...")
	SceneManager.load_into_container(
		SceneRegistry.main_scenes["StartScreen"],
		SceneManager.ContainerType.MENU,
		[SceneManager.ContainerType.LEVEL, SceneManager.ContainerType.HUD],
		"fade_to_black"
	)
	
	# Wait for loading to complete
	await SceneManager.load_complete
	
	# Set game state to MAIN_MENU after boot
	Globals.set_game_state(Globals.GameState.MAIN_MENU)
	
	_boot_complete = true
	print("=== BOOT SEQUENCE COMPLETE ===")
