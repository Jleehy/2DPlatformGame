extends Node

# Game state variables
var main_node: Node
var current_level: Node
var player_progress: Vector2
var level_bounds: Rect2
var death_height_offset: float = 500  # How far below the level bounds the player can fall before dying
var gravity: int = 4000
var terminal_velocity: int = 40000

# Singleton setup
static var instance: GameManager

func _ready() -> void:
	instance = self  # Set the singleton instance

# Initialize level bounds and other gameplay-specific data
func initialize_level(level_id: String) -> void:
	if current_level:
		main_node.remove_child(current_level)

	# Calculate level bounds
	var terrain_node = ResourceLoader.load("res://scenes/main/" + level_id + ".tscn")
	current_level = terrain_node.instantiate()
	main_node.add_child(current_level)
	var tilemap_layer = current_level.get_node("TileMapLayer")
	
	if tilemap_layer:
		level_bounds = tilemap_layer.get_used_rect()
		var cell_size = 16
		level_bounds.position *= cell_size
		level_bounds.size *= cell_size
		
		print(level_bounds)

		# Pass level bounds to the camera manager
		var camera_manager = get_node("/root/CameraManager")
		if camera_manager:
			camera_manager.set_level_bounds(level_bounds)

	# Play music
	AudioManager.play_sound(main_node.get_node("Music"))
	

# Get level bounds
func get_level_bounds() -> Rect2:
	return level_bounds

# Get death height offset
func get_death_height_offset() -> float:
	return death_height_offset

# Get gravity
func get_gravity() -> int:
	return gravity

# Get terminal velocity
func get_terminal_velocity() -> int:
	return terminal_velocity

# Save player progress
func save_checkpoint(position: Vector2) -> void:
	player_progress = position
	print("Checkpoint saved at: ", position)

# Kill the player
func kill_player(player) -> void:
	player.death_timer = 30
	player.velocity = Vector2.ZERO

# Respawn the player
func respawn_player(player) -> void:
	print("Respawning player at last checkpoint:", player_progress)
	player.velocity = Vector2.ZERO
	player.position = player_progress
