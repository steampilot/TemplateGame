class_name Player extends Node

## Player - Omnipräsent (auch wenn unsichtbar)
## State Machine (LSL-style) für Player-Logik

## State Machine
enum State {
	IDLE,           ## Player ist idle (z.B. im Menü)
	ACTIVE,         ## Player spielt aktiv (z.B. Karten ziehen)
	WAITING,        ## Player wartet (z.B. Animation läuft)
	DISABLED        ## Player kann nicht interagieren (z.B. während Transition)
}

var current_state:State = State.IDLE

func _ready() -> void:
	# State Machine startet im default state
	_change_state(State.IDLE)

## State Machine - Change State
func _change_state(new_state:State) -> void:
	# state_exit für aktuellen State
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
	
	# state_entry für neuen State
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
	# Player existiert, aber macht nichts
	pass

func _state_exit_idle() -> void:
	pass

## ============================================
## STATE: ACTIVE
## ============================================
func _state_entry_active() -> void:
	# Player kann interagieren
	pass

func _state_exit_active() -> void:
	pass

## ============================================
## STATE: WAITING
## ============================================
func _state_entry_waiting() -> void:
	# Player wartet (z.B. auf Animation)
	pass

func _state_exit_waiting() -> void:
	pass

## ============================================
## STATE: DISABLED
## ============================================
func _state_entry_disabled() -> void:
	# Player komplett deaktiviert
	pass

func _state_exit_disabled() -> void:
	pass
