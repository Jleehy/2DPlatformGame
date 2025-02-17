extends Node

@onready var player: Node = $Player

func _ready() -> void:
	# Initialize the GameManager with the current level
	CameraManager.set_player(player)
	GameManager.initialize_level(self)
