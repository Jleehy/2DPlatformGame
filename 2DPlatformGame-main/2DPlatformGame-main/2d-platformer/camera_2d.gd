extends Camera2D

# Reference to the player node
var player: Node
var level_bounds: Rect2  # Rect of the level's boundaries
var start_position: Vector2

func _ready() -> void:
	player = get_node("/root/Main/Player")  # Replace with the actual player node path
	level_bounds = get_node("/root/Main/Level/TileMapLayer").get_used_rect() # Get level bounds

	start_position = player.position

	var cellsize = 16;
	level_bounds.position.x *= cellsize;
	level_bounds.position.y *= cellsize;
	level_bounds.size.x *= cellsize;
	level_bounds.size.y *= cellsize;

func _process(delta: float) -> void:
	# Ensure the camera follows the player and stays within bounds
	var target_position = player.position

	# Half width and height of the camera view (for centering the camera)
	var half_width = get_viewport().size.x / 2
	var half_height = get_viewport().size.y / 2
	
	offset.x = 0;
	offset.y = 0;

	if (player.position.x < level_bounds.position.x + half_width) and (player.position.x > level_bounds.position.x + level_bounds.size.x - half_width):
		offset.x = (level_bounds.position.x + (level_bounds.size.x / 2)) - player.position.x

	elif player.position.x < level_bounds.position.x + half_width:
		offset.x = (level_bounds.position.x + half_width) - player.position.x
		
	elif player.position.x > level_bounds.position.x + level_bounds.size.x - half_width:
		offset.x = (level_bounds.position.x + level_bounds.size.x - half_width) - player.position.x
		
	if (player.position.y < level_bounds.position.y + half_height) and (player.position.y > level_bounds.position.y + level_bounds.size.y - half_height):
		offset.y = (level_bounds.position.y + (level_bounds.size.y / 2)) - player.position.y

	elif player.position.y < level_bounds.position.y + half_height:
		offset.y = (level_bounds.position.y + half_height) - player.position.y
		
	elif player.position.y > level_bounds.position.y + level_bounds.size.y - half_height:
		offset.y = (level_bounds.position.y + level_bounds.size.y - half_height) - player.position.y
		
