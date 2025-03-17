extends Node

@onready var player: Node = $Player

func _ready() -> void:
	# Initialize the GameManager with the current level
	CameraManager.set_player(player)
	GameManager.initialize_level("level_2")
	player.dash_unlocked = true
	GameManager.level2_unlocked = true 
