extends Node

@onready var player: Node = $Player


func _ready() -> void:
	# Initialize the GameManager with the current level
	CameraManager.set_player(player)
	GameManager.initialize_level("level_1")

func _process(delta):
	if Input.is_action_just_pressed("pause"):  # Check for pause input
		process_mode = PROCESS_MODE_DISABLED  # Pause the game
		
