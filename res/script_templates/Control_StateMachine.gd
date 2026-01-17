# meta-name: State Machine (LSL-style)
# meta-description: Control with State Machine pattern
# meta-default: true

extends _BASE_

## State Machine (LSL-style)
enum State {
	DEFAULT,    ## Default state
}

var current_state:State = State.DEFAULT


func _ready() -> void:
	_change_state(State.DEFAULT)


## State Machine - Change State
func _change_state(new_state:State) -> void:
	# state_exit für aktuellen State
	match current_state:
		State.DEFAULT:
			_state_exit_default()
	
	current_state = new_state
	print("%s State: %s" % [name, State.keys()[current_state]])
	
	# state_entry für neuen State
	match current_state:
		State.DEFAULT:
			_state_entry_default()


## ============================================
## STATE: DEFAULT
## ============================================
func _state_entry_default() -> void:
	pass


func _state_exit_default() -> void:
	pass
