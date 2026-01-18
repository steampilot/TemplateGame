class_name Main extends Node

## Main persistent scene - State Machine (LSL-style)
## This scene stays loaded throughout the entire game session
## The stage (Main) transitions between different states

## Signals
signal boot_ready  ## Emitted when boot process is complete and game is ready to start

@onready var player:Player = $Player  ## Player is omnipresent (even when invisible)
@onready var level_container:Node = $LevelContainer
@onready var hud_container:Node = $HudContainer
@onready var menu_container:Node = $MenuContainer
@onready var transition_container:Node = $TransitionContainer
@onready var boot_screen:Node = $BootScreen  ## Boot screen - direct child of Main
@onready var boot_start_button:Button = $BootScreen/StartButton if has_node("BootScreen/StartButton") else null  ## Start button (optional)

## State Machine
enum State {
	BOOT,           ## Initial boot state - one-time boot process
	MAIN_MENU,      ## Main menu state
	PLAYING,        ## Game is being played
	PAUSED          ## Game paused (settings, etc.)
}

var current_state:State = State.BOOT

func _ready() -> void:
	# Connect to InputManager signals
	InputManager.main_menu_requested.connect(_on_main_menu_requested)
	InputManager.fullscreen_requested.connect(_on_fullscreen_requested)
	
	# State machine starts in default state
	_change_state(State.BOOT)

## State Machine - Change State
func _change_state(new_state:State) -> void:
	# State exit for current state
	match current_state:
		State.BOOT:
			_state_exit_boot()
		State.MAIN_MENU:
			_state_exit_main_menu()
		State.PLAYING:
			_state_exit_playing()
		State.PAUSED:
			_state_exit_paused()
	
	current_state = new_state
	print("Main State: %s" % State.keys()[current_state])
	
	# State entry for new state
	match current_state:
		State.BOOT:
			_state_entry_boot()
		State.MAIN_MENU:
			_state_entry_main_menu()
		State.PLAYING:
			_state_entry_playing()
		State.PAUSED:
			_state_entry_paused()

## ============================================
## STATE: BOOT (default state)
## ============================================
func _state_entry_boot() -> void:
	print("=== STATE: BOOT ===")
	
	# Main starts with black background
	# All containers are invisible
	level_container.visible = false
	hud_container.visible = false
	menu_container.visible = false
	transition_container.visible = false
	
	# Show boot screen (black background + sprite)
	boot_screen.visible = true
	
	# Simulate loading (5 second delay)
	await get_tree().create_timer(5.0).timeout
	
	# Boot complete - emit signal for BootScreen to show Start button
	boot_ready.emit()
	print("Boot complete - ready signal emitted")

func _state_exit_boot() -> void:
	# Hide boot screen when leaving state
	boot_screen.visible = false

## ============================================
## STATE: MAIN_MENU
## ============================================
func _state_entry_main_menu() -> void:
	print("=== STATE: MAIN_MENU ===")
	# Main is now the boss - no more Globals

func _state_exit_main_menu() -> void:
	pass

## ============================================
## STATE: PLAYING
## ============================================
func _state_entry_playing() -> void:
	print("=== STATE: PLAYING ===")
	# Main controls its own state

func _state_exit_playing() -> void:
	pass

## ============================================
## STATE: PAUSED
## ============================================
func _state_entry_paused() -> void:
	print("=== STATE: PAUSED ===")
	get_tree().paused = true

func _state_exit_paused() -> void:
	get_tree().paused = false

## ============================================
## INPUT HANDLERS
## ============================================
## Called when main_menu action triggered (via InputManager)
func _on_main_menu_requested() -> void:
	# State-dependent behavior
	match current_state:
		State.PLAYING:
			_change_state(State.PAUSED)
		State.PAUSED:
			_change_state(State.PLAYING)
		_:
			pass  # Ignore in other states

## Called when toggle_fullscreen action triggered (via InputManager)
func _on_fullscreen_requested() -> void:
	DisplayManager.toggle_fullscreen()
