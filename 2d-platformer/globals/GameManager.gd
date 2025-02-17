extends Node

var current_level: Node
var player_progress: Vector2
var level_bounds: Rect2
var death_height_offset: float = 500  # How far below the level bounds the player can fall before dying

func _ready() -> void:
	var level_to_load: Node = get_node("/root/Main/Level")
	load_level(level_to_load)

func load_level(level: Node) -> void:
	current_level = level
	print("Loading level: ", level)
	
	# Calculate level bounds
	var tilemap_layer = level.get_node("TileMapLayer")
	level_bounds = tilemap_layer.get_used_rect()
	
	var cell_size = 16
	level_bounds.position *= cell_size
	level_bounds.size *= cell_size
	
	# Pass level bounds and death height to the player
	var player = get_node("/root/Main/Player")
	if player:
		player.set_level_bounds(level_bounds, death_height_offset)
	
	# Pass level bounds to the camera manager
	var camera_manager = get_node("/root/CameraManager")
	if camera_manager:
		print("G")
		camera_manager.set_level_bounds(level_bounds)
	
	# Play music
	AudioManager.play_sound(get_node("/root/Main/Music"))

func save_checkpoint(position: Vector2) -> void:
	player_progress = position
	print("Checkpoint saved at: ", position)
