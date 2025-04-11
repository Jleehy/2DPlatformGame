extends Camera2D

# Player and level bounds references
var player: Node = null
var level_bounds: Rect2 = Rect2()

var display_label: Label = null

# Set the player dynamically
func set_player(new_player: Node) -> void:
	player = new_player

# Set the level bounds dynamically
func set_level_bounds(bounds: Rect2) -> void:
	level_bounds = bounds

func _process(delta: float) -> void:
	# If no player is set, default to main menu
	if not player:
		position = Vector2(1280/2, 720/2)
		return
	
	# If no level bounds are set, default to following the player without clamping
	if level_bounds == Rect2():
		position = player.position
		return
	
	# Get the player's target position
	var target_position = player.position
	
	# Half width and height of the camera view (for centering the camera)
	var half_width = get_viewport_rect().size.x / 2
	var half_height = get_viewport_rect().size.y / 2
	
	# Clamp camera position to ensure it doesn't move outside level bounds
	var clamped_x = clamp(target_position.x, level_bounds.position.x + half_width, level_bounds.end.x - half_width)
	var clamped_y = clamp(target_position.y, level_bounds.position.y + half_height, level_bounds.end.y - half_height)
	
	# Set camera position
	position = Vector2(clamped_x, clamped_y)


func display_display_text(display_active: bool, text: String) -> void:
	# Called from gamemanager
	if not display_active:
		if display_label:
			display_label.queue_free()
			display_label = null
		return

	# Create the label if it doesn't exist
	if not display_label:
		display_label = Label.new()
		add_child(display_label)
		display_label.reset_size()
		display_label.scale = Vector2(3, 3)
		display_label.add_theme_color_override("font_color", Color(0, 0, 0))
		display_label.z_index = 100

	# Update the label's properties
	display_label.text = text

	# Position the label at the center of the screen
	var scale_amount = 10
	
	display_label.position = Vector2(-550, 200)
