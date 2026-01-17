class_name Player extends Node2D

## Persistent player node that exists throughout the game
## For card games: invisible but holds camera and game state
## For platformers: visible with sprite and collision

@onready var camera:Camera2D = $Camera2D

var player_visible:bool = false:
	set(value):
		player_visible = value
		visible = value

func _ready() -> void:
	# For card games, player is not visible
	player_visible = false
