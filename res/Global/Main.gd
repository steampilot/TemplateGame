class_name Main extends Node

## Main persistent scene - State Machine (LSL-style)
## This scene stays loaded throughout the entire game session
## Die Bühne (Main) wechselt zwischen verschiedenen States

@onready var player:Player = $Player  ## Player ist omnipräsent (auch wenn unsichtbar)
@onready var level_container:Node = $LevelContainer
@onready var hud_container:Node = $HudContainer
@onready var menu_container:Node = $MenuContainer
@onready var transition_container:Node = $TransitionContainer
@onready var boot_screen:Node = $BootScreen  ## Boot Screen - direktes Child von Main
@onready var boot_start_button:Button = $BootScreen/StartButton if has_node("BootScreen/StartButton") else null  ## Start Button (optional)

## State Machine
enum State {
	BOOT,           ## Initial boot state - Einmaliger Boot-Prozess
	MAIN_MENU,      ## Main menu state
	PLAYING,        ## Game is being played
	PAUSED          ## Game paused (settings, etc.)
}

var current_state:State = State.BOOT

func _ready() -> void:
	# Connect to InputManager signals
	InputManager.main_menu_requested.connect(_on_main_menu_requested)
	
	# State Machine startet im default state
	_change_state(State.BOOT)

## State Machine - Change State
func _change_state(new_state:State) -> void:
	# state_exit für aktuellen State
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
	
	# state_entry für neuen State
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
	
	# Main startet mit schwarzem Hintergrund
	# Alle Container sind unsichtbar
	level_container.visible = false
	hud_container.visible = false
	menu_container.visible = false
	transition_container.visible = false
	
	# Boot Screen anzeigen (schwarzer Hintergrund + Sprite)
	boot_screen.visible = true
	
	# Start Button (falls vorhanden)
	if boot_start_button != null:
		boot_start_button.visible = false  # Button initial versteckt
		
		# 3 Sekunden Delay
		await get_tree().create_timer(3.0).timeout
		
		# Start Button einblenden
		boot_start_button.visible = true
		boot_start_button.pressed.connect(_on_boot_start_pressed)
		
		print("Boot screen ready - waiting for Start button")
	else:
		print("Boot screen visible - no Start button found")

func _state_exit_boot() -> void:
	# Boot Screen verstecken wenn wir den State verlassen
	boot_screen.visible = false
	if boot_start_button != null and boot_start_button.pressed.is_connected(_on_boot_start_pressed):
		boot_start_button.pressed.disconnect(_on_boot_start_pressed)

## Start Button wurde geklickt
func _on_boot_start_pressed() -> void:
	print("Start button pressed!")
	# Hier später: _change_state(State.MAIN_MENU)
	# Für jetzt: einfach nur das Signal bestätigen

## ============================================
## STATE: MAIN_MENU
## ============================================
func _state_entry_main_menu() -> void:
	print("=== STATE: MAIN_MENU ===")
	# Main ist jetzt der Boss - keine Globals mehr

func _state_exit_main_menu() -> void:
	pass

## ============================================
## STATE: PLAYING
## ============================================
func _state_entry_playing() -> void:
	print("=== STATE: PLAYING ===")
	# Main kontrolliert seinen eigenen State

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
## Called when player presses ESC (via InputManager)
func _on_main_menu_requested() -> void:
	# State-dependent behavior
	match current_state:
		State.PLAYING:
			_change_state(State.PAUSED)
		State.PAUSED:
			_change_state(State.PLAYING)
		_:
			pass  # Ignore in other states
