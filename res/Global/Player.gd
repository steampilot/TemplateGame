class_name Player extends Node

## Player - Omnipresent (even when invisible)
## State Machine (LSL-style) for player logic

## State Machine
enum State {
	IDLE,           ## Player is idle (e.g. in menu)
	ACTIVE,         ## Player actively playing (e.g. drawing cards)
	WAITING,        ## Player waiting (e.g. animation running)
	DISABLED        ## Player cannot interact (e.g. during transition)
}

var current_state:State = State.IDLE

func _ready() -> void:
	# State machine starts in default state
	_change_state(State.IDLE)

## State Machine - Change State
func _change_state(new_state:State) -> void:
	# State exit for current state
	match current_state:
		State.IDLE:
			_state_exit_idle()
		State.ACTIVE:
			_state_exit_active()
		State.WAITING:
			_state_exit_waiting()
		State.DISABLED:
			_state_exit_disabled()
	
	current_state = new_state
	print("Player State: %s" % State.keys()[current_state])
	
	# State entry for new state
	match current_state:
		State.IDLE:
			_state_entry_idle()
		State.ACTIVE:
			_state_entry_active()
		State.WAITING:
			_state_entry_waiting()
		State.DISABLED:
			_state_entry_disabled()

## ============================================
## STATE: IDLE (default state)
## ============================================
func _state_entry_idle() -> void:
	# Player exists but does nothing
	pass

func _state_exit_idle() -> void:
	pass

## ============================================
## STATE: ACTIVE
## ============================================
func _state_entry_active() -> void:
	# Player can interact
	pass

func _state_exit_active() -> void:
	pass

## ============================================
## STATE: WAITING
## ============================================
func _state_entry_waiting() -> void:
	# Player waiting (e.g. for animation)
	pass

func _state_exit_waiting() -> void:
	pass

## ============================================
## STATE: DISABLED
## ============================================
func _state_entry_disabled() -> void:
	# Player completely disabled
	pass

func _state_exit_disabled() -> void:
	pass
