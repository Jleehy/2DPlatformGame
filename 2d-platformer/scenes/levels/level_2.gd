extends Node

@onready var player: Node = $Player

func _ready() -> void:
	# Initialize the GameManager with the current level
	CameraManager.set_player(player)
	GameManager.initialize_level("level_2")
	player.dash_unlocked = true
	GameManager.level2_unlocked = true

func _process(delta: float) -> void:
	for child in get_children():
		if is_instance_of(child, Plant):
			child.set_direction(player.position.x - child.position.x)
