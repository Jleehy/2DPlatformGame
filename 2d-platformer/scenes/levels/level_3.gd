extends Node

@onready var player: Node = $Player

func _ready() -> void:
	# Initialize the GameManager with the current level
	var transition = $CanvasLayer2/Transition 
	player.player_died.connect(transition.fade_in)
	player.player_respawned.connect(transition.fade_out)
	player.dash_unlocked = true
	player.grapple_unlocked = true
	GameManager.current_level_number = 3
	GameManager.level3_unlocked = true
	for child in get_children():
		if is_instance_of(child, Skull):
			child.attach_player(player)
	GameManager.initialize_level("level_3")
	CameraManager.set_player(player)


func _process(delta: float) -> void:
	#set up plants and allow them to shoot.
	for child in get_children():
		if is_instance_of(child, Plant):
			child.set_direction(player.position.x - child.position.x)
			child.set_shoot(abs(player.position.y - child.position.y) < 100)
