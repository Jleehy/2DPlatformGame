extends CharacterBody2D

# Player physics variables
@export var speed: int = 300
@export var jump_speed: int = -1200
@export var gravity: int = 4000

# Advanced physics variables
@export var minimum_speed_percentage: float = 0.30
@export var player_input_acceleration_percent: float = 0.25
@export var friction_value: float = 0.84
@export var air_control_loss: float = 0.30
@export var facing_direction: String = "left"
@export var terminal_velocity: int = 40000

var level_bounds: Rect2
var death_height_offset: float
var last_spawn: Vector2

func set_level_bounds(bounds: Rect2, death_offset: float) -> void:
	level_bounds = bounds
	death_height_offset = death_offset

func _ready() -> void:
	$AnimatedSprite2D.play()
	position = self.position
	set_save()

func _physics_process(delta: float) -> void:
	# Handle movement and physics
	if is_on_floor():
		if abs(velocity.x) < speed * minimum_speed_percentage:
			if not InputManager.is_move_left_pressed() and not InputManager.is_move_right_pressed():
				velocity.x = 0
		else:
			velocity.x *= friction_value
		
		if InputManager.is_move_left_pressed():
			velocity.x += -speed * player_input_acceleration_percent
			facing_direction = "left"
		if InputManager.is_move_right_pressed():
			velocity.x += speed * player_input_acceleration_percent
			facing_direction = "right"
	else:
		if abs(velocity.x) < speed * (minimum_speed_percentage * air_control_loss):
			if not InputManager.is_move_left_pressed() and not InputManager.is_move_right_pressed():
				velocity.x = 0
		else:
			velocity.x *= (1 - ((1 - friction_value) * air_control_loss))
		
		if InputManager.is_move_left_pressed():
			velocity.x += -speed * air_control_loss * player_input_acceleration_percent
			facing_direction = "left"
		if InputManager.is_move_right_pressed():
			velocity.x += speed * air_control_loss * player_input_acceleration_percent
			facing_direction = "right"

	# Apply gravity and terminal velocity
	velocity.y += gravity * delta
	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity

	# Update animation
	update_animation()

	# Handle level bounds and death
	if position.x < level_bounds.position.x + 16:
		position.x = level_bounds.position.x + 16
		if velocity.x < 0:
			velocity.x = 0
	elif position.x > level_bounds.position.x + level_bounds.size.x - 16:
		position.x = level_bounds.position.x + level_bounds.size.x - 16
		if velocity.x > 0:
			velocity.x = 0
	
	# Check for death (falling below level bounds + death height offset)
	if position.y > level_bounds.position.y + level_bounds.size.y + death_height_offset:
		die()

	# Move the player
	move_and_slide()

	# Handle jumping
	if InputManager.is_jump_pressed() and is_on_floor():
		velocity.y = jump_speed

func update_animation() -> void:
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.flip_h = facing_direction == "left"
		if is_on_floor():
			$AnimatedSprite2D.animation = "run"
		else:
			if velocity.y < 0:
				$AnimatedSprite2D.animation = "jump"
			else:
				$AnimatedSprite2D.animation = "fall"
	else:
		$AnimatedSprite2D.animation = "idle"

func set_save() -> void:
	last_spawn = position

func die() -> void:
	print("Died!")
	velocity = Vector2.ZERO
	position = last_spawn
