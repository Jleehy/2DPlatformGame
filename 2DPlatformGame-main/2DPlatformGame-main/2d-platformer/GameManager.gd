extends Node

var current_level: Node
var player_progress: Vector2

func _ready() -> void:
	var level_to_load: Node = get_node("/root/Main/Level")
	load_level(level_to_load)

func load_level(level: Node) -> void:
	current_level = level
	print("Loading level: ", level)
	# DO STUFF
	AudioManager.play_sound(get_node("/root/Main/Music")) # Play music 

func save_checkpoint(position: Vector2) -> void:
	player_progress = position
	print("Checkpoint saved at: ", position)
