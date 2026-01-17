extends Node

## InputManager - Global Input Router mit State Machine (LSL-style)
## Fängt Inputs ab und emittiert Signals für decoupled input handling

## Signals für verschiedene Input-Events
signal main_menu_requested      ## ESC key pressed
signal pause_requested          ## P key pressed
signal settings_requested       ## O key pressed

## State Machine
enum State {
	ACTIVE,         ## Input wird verarbeitet (default)
	BLOCKED,        ## Input wird ignoriert (z.B. während Transitions)
}

var current_state:State = State.ACTIVE


func _ready() -> void:
	_change_state(State.ACTIVE)


## State Machine - Change State
func _change_state(new_state:State) -> void:
	# state_exit für aktuellen State
	match current_state:
		State.ACTIVE:
			_state_exit_active()
		State.BLOCKED:
			_state_exit_blocked()
	
	current_state = new_state
	print("InputManager State: %s" % State.keys()[current_state])
	
	# state_entry für neuen State
	match current_state:
		State.ACTIVE:
			_state_entry_active()
		State.BLOCKED:
			_state_entry_blocked()


## ============================================
## STATE: ACTIVE (default)
## ============================================
func _state_entry_active() -> void:
	# Input processing aktiv
	set_process_input(true)


func _state_exit_active() -> void:
	pass


## ============================================
## STATE: BLOCKED
## ============================================
func _state_entry_blocked() -> void:
	# Input processing deaktiviert
	set_process_input(false)


func _state_exit_blocked() -> void:
	pass


## ============================================
## INPUT PROCESSING
## ============================================
func _input(event:InputEvent) -> void:
	# Nur verarbeiten wenn im ACTIVE State
	if current_state != State.ACTIVE:
		return
	
	# ESC key - Main Menu
	if event.is_action_pressed("main_menu"):
		main_menu_requested.emit()
		get_viewport().set_input_as_handled()
	
	# P key - Pause
	elif event.is_action_pressed("pause_game"):
		pause_requested.emit()
		get_viewport().set_input_as_handled()
	
	# O key - Settings
	elif event.is_action_pressed("settings_menu"):
		settings_requested.emit()
		get_viewport().set_input_as_handled()


## ============================================
## PUBLIC API
## ============================================
## Blockiert Input (z.B. während Transitions)
func block_input() -> void:
	_change_state(State.BLOCKED)


## Aktiviert Input wieder
func unblock_input() -> void:
	_change_state(State.ACTIVE)
