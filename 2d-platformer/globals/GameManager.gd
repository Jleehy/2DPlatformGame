extends Node

# Game state variables
var current_level: Node
var player_progress: Vector2
var level_bounds: Rect2
var death_height_offset: float = 100  # How far below the level bounds the player can fall before dying
var gravity: int = 3500
var terminal_velocity: int = 2000

# Singleton setup
static var instance: GameManager

# Levels Unlocked
var level2_unlocked: bool = false
var level3_unlocked: bool = false

#Some variables that are used internally to handle the dev teleportation
@export var current_level_number: int = 0
@export var current_checkpoint_number: int = 0
@export var checkpoints_list: Array = []

#some "cutscene" (very minor ones) and dialogue box related stuff
@export var enabled_deaths: bool = true

#some variables used by enemies. They access this to have a 
#central counter for some stuffs.
@export var enemy_timer_max: int = 1000
@export var enemy_timer_current: int = 0

@export var dead_position: Vector2 = Vector2(-1000, -1000)

#variables related to the displayed text
@export var display_text_timer: int = 500
@export var display_text = ""

#variable related to whether or not death transition is playing
var is_transitioning: bool = false

#a list that contains start-of-level messages
@export var start_level_messages: Array = [  
	"WELCOME TO HOPPER! USE ARROWS OR WASD TO MOVE. SIGNS CONTAIN FURTHER INFORMATION.",  
	"FROG DISCOVERS HE IS THE PRINCE OF HIS KINGDOM AND SHOULD NOT BE ADVENTURING",  
	"TODO"  
]  
#a list of lists that handle specific sign messages within levels
@export var sign_messages_list: Array = [  
	[  
		"1",
		"2",
		"3",
		"4",
		"That is all for the tutorial! Jump down below to enter the level proper.".to_upper(),
		"Use T to send yourself back to the most recent checkpoint. Maybe this is useful here...".to_upper(),
		"Hold Down or S to crouch in smaller gaps.".to_upper(),
		"Down-right, there is an new Checkpoint to get. Up-Left, there is an enemy. Stomp enemies to defeat!".to_upper(),
		"The Spikes will send you back to the previous checkpoint.".to_upper(),
		"Use space to Jump!".to_upper(),
		"11",
		"12"
	],  
	[  
		"EVERY TADPOLE DREAMS OF GREATNESS WHEN THEY BECOME A FROG\nTHIS IS YOUR DESTINY",  
		"THIS ROAD SIGN MARKS THE CITY CENTER\nTHE LEADER MUST BE NEAR",  
		"THIS IS THE ROYAL ACADEMY\nSTRANGELY SIMILAR TO YOUR OWN",  
		"THE ROYAL RESIDENCE IS AHEAD\nYOU ARE ON THE RIGHT PATH",  
		"Use the shift key to use your newly-unlocked dash!".to_upper(),  
		"6"  
	],  
	[
		"Use the Q key to use your newly-unlocked grapple!".to_upper()
	]  
]  
@export var sign_manager_counter: int = 0

func _ready() -> void:
	instance = self  # Set the singleton instance
	enemy_timer_current = 0

func _physics_process(delta: float) -> void:
	#just a loop to handle the counter
	enemy_timer_current += 1
	if enemy_timer_current > enemy_timer_max:
		enemy_timer_current = 0
		
	#display any text
	handle_text_display()

# Initialize level bounds and other gameplay-specific data
func initialize_level(level_id: String) -> void:
	#set up for dev tool automation thing
	
	var transition = get_node("/root/" + level_id + "/CanvasLayer2/Transition")
	if transition:
		print("LEVEL ID: " + level_id)
		transition.fade_in("LEVEL " + str(current_level_number))
		
		await get_tree().create_timer(3).timeout
		
		transition.fade_out()

	# Calculate level bounds
	current_level = get_node("/root/" + level_id)
	var tilemap_layer = current_level.get_node("TileMapLayer")
	
	#reset sign counter
	sign_manager_counter = 0
	
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

	#display start text
	display_text_timer = 350
	display_text = start_level_messages[current_level_number-1]

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
		
		player.health = 0
		player.block_heart_display = true
		player.update_heart_display()
		
		display_text_timer = 0
		
		#go through all bodies and call a reset on them if applicable.
		#wait for fade to have happened to reset all of these things.
		await get_tree().create_timer(3.0).timeout
		for node in get_tree().current_scene.get_children():
			if node.has_method("reset_position"):
				node.reset_position()
			
			if node.has_method("heal_and_respawn"):
				node.heal_and_respawn()
			
			if node.has_method("despawn"):
				node.despawn()

# Respawn the player
func respawn_player(player) -> void:
	if player_progress == dead_position:
		#set the position to the start point position.
		player_progress = [Vector2(467, -1545), Vector2(227, 713), Vector2(227, 713)][current_level_number]
	
	print("Respawning player at last checkpoint:", player_progress)
	player.velocity = Vector2.ZERO
	player.position = player_progress
	print("Player current position: ", player.position)
	print("Player current global position: ", player.global_position)

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
	
func handle_text_display() -> void:
	#handle the text display
	#first update variables
		
	if not current_level:
		#menu no text
		CameraManager.display_display_text(false, display_text)
		return
		
	if display_text_timer <= 0:
		#a check to make a flare of the text work
		CameraManager.display_display_text(false, display_text)
		display_text_timer = 0
			
	else:
		CameraManager.display_display_text(true, display_text)
		display_text_timer -= 1
	
	
