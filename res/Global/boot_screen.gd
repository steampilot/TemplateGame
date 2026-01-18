extends Control
## BootScreen - Displays boot splash and start button
## Listens for Main's boot_ready signal to show Start button

@onready var start_button:Button = %StartButton

## State Machine
enum State {
	DEFAULT,    ## Waiting for boot to complete
}

var current_state:State = State.DEFAULT

func _ready() -> void:
	# State machine starts in default state
	_change_state(State.DEFAULT)

## State Machine - Change State
func _change_state(new_state:State) -> void:
	# State exit for current state
	match current_state:
		State.DEFAULT:
			_state_exit_default()
	
	current_state = new_state
	print("BootScreen State: %s" % State.keys()[current_state])
	
	# State entry for new state
	match current_state:
		State.DEFAULT:
			_state_entry_default()

## ============================================
## STATE: DEFAULT
## ============================================
func _state_entry_default() -> void:
	# Button starts hidden
	start_button.visible = false
	
	# Get reference to Main and connect to boot_ready signal
	var main = get_parent()
	if main and main is Main:
		main.boot_ready.connect(_on_boot_ready)
		print("BootScreen: Connected to Main's boot_ready signal")
	else:
		push_error("BootScreen: Could not find Main parent!")

func _state_exit_default() -> void:
	pass

## ============================================
## SIGNAL HANDLERS
## ============================================
## Called when Main emits boot_ready signal
func _on_boot_ready() -> void:
	print("BootScreen: Boot ready signal received - showing Start button")
	start_button.visible = true
