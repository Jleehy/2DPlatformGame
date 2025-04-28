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
	
	if is_typing and display_label:
		# Advance the typewriter effect
		typewriter_progress += typewriter_speed * delta
		display_label.visible_ratio = min(typewriter_progress / float(current_text.length()), 1.0)
		
		# Check if typing is complete
		if display_label.visible_ratio >= 1.0:
			is_typing = false


var typewriter_speed: float = 40.0  # characters per second
var typewriter_progress: float = 0.0
var current_text: String = ""
var is_typing: bool = false

#used to manage the text being printed onto screen
func display_display_text(display_active: bool, text: String) -> void:
	# Called from gamemanager
	if not display_active:
		if display_label:
			display_label.queue_free()
			display_label = null
		is_typing = false
		current_text = ""
		typewriter_progress = 0.0
		return

	# Create the label if it doesn't exist
	if not display_label:
		var theme_resource = load("res://menus/text.tres")
		display_label = Label.new()
		add_child(display_label)
		
		# Disable auto-resizing 
		display_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		display_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN 
		display_label.autowrap_mode = TextServer.AUTOWRAP_WORD 
			
		# Set the label's size and position
		display_label.size = Vector2(1100, 500) 
		display_label.position = Vector2(-540, 250)
		
		display_label.scale = Vector2(1, 1)
		display_label.theme = theme_resource
		display_label.z_index = 100
	
	# Check if text has changed
	if text != current_text:
		current_text = text
		typewriter_progress = 0.0
		is_typing = true
		display_label.visible_ratio = 0.0
		display_label.text = text  # Set full text immediately but only show portion based on visible_ratio
