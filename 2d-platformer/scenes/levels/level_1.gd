extends Node

@onready var player: Node = $Player


func _ready() -> void:
	# Initialize the GameManager with the current level
	var transition = $CanvasLayer2/Transition 
	player.player_died.connect(transition.fade_in)
	player.player_respawned.connect(transition.fade_out)
	CameraManager.set_player(player)
	GameManager.initialize_level("level_1")

func _process(delta):
	if Input.is_action_just_pressed("pause"):  # Check for pause input
		process_mode = PROCESS_MODE_DISABLED  # Pause the game
		
