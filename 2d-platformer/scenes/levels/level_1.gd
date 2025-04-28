extends Node

@onready var player: Node = $Player


func _ready() -> void:
	# Initialize the GameManager with the current level
	var transition = $CanvasLayer2/Transition 
	print(transition)
	player.player_died.connect(transition.fade_in)
	player.player_respawned.connect(transition.fade_out)
	player.grapple_unlocked = false
	player.dash_unlocked = false
	GameManager.current_level_number = 1
	GameManager.initialize_level("level_1")
	CameraManager.set_player(player)
