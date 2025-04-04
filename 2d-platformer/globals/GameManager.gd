extends Node

# Game state variables
var current_level: Node
var player_progress: Vector2
var level_bounds: Rect2
var death_height_offset: float = 100  # How far below the level bounds the player can fall before dying
var gravity: int = 3500
var terminal_velocity: int = 12000

# Singleton setup
static var instance: GameManager

# Levels Unlocked
var level2_unlocked: bool = false

#Some variables that are used internally to handle the dev teleportation
@export var current_level_number: int = 0
@export var current_checkpoint_number: int = 0
@export var checkpoints_list: Array = []

#some "cutscene" (very minor ones) and dialogue box related stuff
@export var enabled_deaths: bool = true

func _ready() -> void:
	instance = self  # Set the singleton instance

# Initialize level bounds and other gameplay-specific data
func initialize_level(level_id: String) -> void:
	#set up for dev tool automation thing
	
	# Calculate level bounds
	current_level = get_node("/root/" + level_id)
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
	#AudioManager.play_sound(main_node.get_node("Music"))
	

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
func save_checkpoint(position_in: Vector2) -> void:
	player_progress = position_in
	print("Checkpoint saved at: ", position_in)
	
	#save the player's current checkpoint. Kinda janky implementation here
	#idk maybe fix later. It is a dev tool tho so idk.
	#see if player's current level is within the levels catalogued for checkpoints.
	if current_level_number < 0 or len(checkpoints_list) == 0:
		return
		
	#ok, go through to find the checkpoint of matching position.
	var checkpoint_check_index = -1
	while checkpoint_check_index < len(checkpoints_list) - 1:
		checkpoint_check_index += 1
		var position_check = checkpoints_list[checkpoint_check_index]
		
		if position_check == position_in:
			current_checkpoint_number = checkpoint_check_index
			print("New Checkpoint Number: ", current_checkpoint_number)
			return

# Kill the player
func kill_player(player) -> void:
	if (enabled_deaths):
		player.death_timer = 30
		player.velocity = Vector2.ZERO

# Respawn the player
func respawn_player(player) -> void:
	print("Respawning player at last checkpoint:", player_progress)
	player.velocity = Vector2.ZERO
	player.position = player_progress

func next_checkpoint_teleport(player) -> void:
	#if invalid setup for current level, then do nothing.
	if current_level_number < 0 or len(checkpoints_list) == 0:
		return

	#next see if at the last checkpoint. If so, do nothing.
	if current_checkpoint_number == len(checkpoints_list) - 1:
		return
		
	player.global_position = checkpoints_list[current_checkpoint_number + 1]
	current_checkpoint_number += 1
	
func prev_checkpoint_teleport(player) -> void:
	#if invalid setup for current level, then do nothing.
	if current_level_number < 0 or len(checkpoints_list) == 0:
		return

	#next see if at the first checkpoint. If so, do nothing.
	if current_checkpoint_number == 0:
		return
		
	#now teleport the player
	player.global_position = checkpoints_list[current_checkpoint_number - 1]
	current_checkpoint_number -= 1

func enable_deaths() -> void:
	enabled_deaths = true
	
func disable_deaths() -> void:
	enabled_deaths = false
