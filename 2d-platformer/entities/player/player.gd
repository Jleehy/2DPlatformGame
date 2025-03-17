extends CharacterBody2D

# Player physics variables
@export var speed: int = 325
@export var jump_speed: int = -1050

# Sound effects
@onready var sfx_dash = $sfx_dash
@onready var sfx_jump  = $sfx_jump
@onready var sfx_death  = $sfx_death

# Advanced physics variables
@export var minimum_speed_percentage: float = 0.30
@export var player_input_acceleration_percent: float = 0.25
@export var friction_value: float = 0.84
@export var air_control_loss: float = 0.35
@export var facing_direction: String = "left"

#crouching variables
@export var crouch_speed_reduction: float = 0.50
@export var is_crouching: bool = false
@export var original_collision_size: Vector2
@export var crouch_squish_amount: float = 0.75

# Dash and other Movement variables
@export var dash_speed: float = 1500
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 0.5
@export var dash_unlocked: bool = false
var is_dashing: bool = false
var can_dash: bool = true

@export var death_timer: int = -1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dash_effect: Sprite2D = $DashEffect

func _ready() -> void:
	animated_sprite.play()
	GameManager.save_checkpoint(self.position)
	
	original_collision_size = collision_shape.shape.size

func _physics_process(delta: float) -> void:
	if death_timer == -1:
		if not is_dashing:
			apply_gravity(delta)
		handle_crouching()
		handle_movement()
		handle_jumping()
		handle_dash()
		handle_level_bounds()
		update_animation()
		move_and_slide()
		handle_self_die()
		dev_checkpoint_handle()
	else:
		handle_death_animation()

func apply_gravity(delta: float) -> void:
	var gravity = GameManager.get_gravity()
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0:
		velocity.y = 0

func handle_movement() -> void:
	if is_on_floor():
		handle_ground_movement()
	else:
		handle_air_movement()

func handle_ground_movement() -> void:
	if abs(velocity.x) < speed * minimum_speed_percentage:
		if not InputManager.is_move_left_pressed() and not InputManager.is_move_right_pressed():
			velocity.x = 0
	else:
		velocity.x *= friction_value

	apply_horizontal_movement(1.0)

func handle_air_movement() -> void:
	if abs(velocity.x) < speed * (minimum_speed_percentage * air_control_loss):
		if not InputManager.is_move_left_pressed() and not InputManager.is_move_right_pressed():
			velocity.x = 0
	else:
		velocity.x *= (1 - ((1 - friction_value) * air_control_loss))

	apply_horizontal_movement(air_control_loss)

func apply_horizontal_movement(control_factor: float) -> void:
	if InputManager.is_move_left_pressed():
		velocity.x += -speed * control_factor * player_input_acceleration_percent
		facing_direction = "left"
	if InputManager.is_move_right_pressed():
		velocity.x += speed * control_factor * player_input_acceleration_percent
		facing_direction = "right"

func handle_jumping() -> void:
	if InputManager.is_jump_pressed() and is_on_floor():
		sfx_jump.play()
		velocity.y = jump_speed

func handle_dash() -> void:
	if not dash_unlocked:
		return  # Prevent dashing if not unlocked
	if not can_dash:
		modulate = Color(0.5, 0.5, 1, 1)
		
	else:
		modulate = Color(1, 1, 1, 1)
		
	if InputManager.is_dash_pressed() and can_dash and not is_dashing:
		sfx_dash.play()
		start_dash()

func start_dash() -> void:
	is_dashing = true
	can_dash = false

	# Copy the current frame of the player's animation to the dash effect
	var frameIndex: int = animated_sprite.get_frame()
	var animationName: String = animated_sprite.animation
	var spriteFrames: SpriteFrames = animated_sprite.get_sprite_frames()
	var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
	
	dash_effect.texture = currentTexture
	dash_effect.flip_h = animated_sprite.flip_h
	dash_effect.visible = true

	# Set dash velocity based on facing direction
	var dash_direction: Vector2 = Vector2.RIGHT if facing_direction == "right" else Vector2.LEFT
	velocity = dash_direction * dash_speed

	# Start dash duration timer
	await get_tree().create_timer(dash_duration).timeout
	end_dash()

	# Start dash cooldown timer
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func end_dash() -> void:
	is_dashing = false
	velocity.x = 0
	dash_effect.visible = false

func handle_level_bounds() -> void:
	var level_bounds = GameManager.get_level_bounds()
	var death_height_offset = GameManager.get_death_height_offset()

	if self.position.x < level_bounds.position.x + 16:
		self.position.x = level_bounds.position.x + 16
		if velocity.x < 0:
			velocity.x = 0
	elif self.position.x > level_bounds.position.x + level_bounds.size.x - 16:
		self.position.x = level_bounds.position.x + level_bounds.size.x - 16
		if velocity.x > 0:
			velocity.x = 0

	if self.position.y > level_bounds.position.y + level_bounds.size.y + death_height_offset:
		sfx_death.play()
		GameManager.kill_player(self)

func update_animation() -> void:
	if velocity.x != 0 or velocity.y != 0:
		animated_sprite.flip_h = facing_direction == "left"
		if is_on_floor():
			animated_sprite.animation = "run"
		else:
			if velocity.y < 0:
				animated_sprite.animation = "jump"
			else:
				animated_sprite.animation = "fall"
	else:
		animated_sprite.animation = "idle"

func handle_death_animation() -> void:
	if animated_sprite.rotation_degrees < 90:
		animated_sprite.rotation_degrees += 5
	else:
		animated_sprite.rotation_degrees = 90

	death_timer -= 1
	modulate = Color(1, 0, 0, 1)
	
	
	if death_timer == 0:
		modulate = Color(1, 1, 1, 1)
		animated_sprite.rotation_degrees = 0
		GameManager.respawn_player(self)
		death_timer = -1

func handle_crouching() -> void:
	if InputManager.is_crouch_pressed():
		if not is_crouching:
			is_crouching = true
			speed *= crouch_speed_reduction
			jump_speed *= crouch_speed_reduction
			
			# Calculate the new size and position
			var new_size = Vector2(original_collision_size.x, original_collision_size.y * crouch_squish_amount)
			var size_difference = original_collision_size.y - new_size.y
			
			# Apply the new size and adjust the position
			collision_shape.shape.set_deferred("size", new_size)
			self.global_position.y += size_difference / 2
			
			# Scale the sprite
			animated_sprite.scale = Vector2(1, crouch_squish_amount)
	else:
		if is_crouching:
			is_crouching = false
			speed /= crouch_speed_reduction
			jump_speed /= crouch_speed_reduction
			
			# Calculate the original size and position
			var new_size = original_collision_size
			var size_difference = new_size.y - collision_shape.shape.size.y
			
			# Apply the original size and adjust the position
			collision_shape.shape.set_deferred("size", new_size)
			self.global_position.y -= size_difference / 2
			
			# Reset the sprite scale
			animated_sprite.scale = Vector2(1, 1)

func handle_self_die() -> void:
	if InputManager.is_self_death_pressed():
		GameManager.kill_player(self)

func dev_checkpoint_handle() -> void:
	if InputManager.is_dev_teleport_backwards_pressed():
		GameManager.prev_checkpoint_teleport(self)
		
	if InputManager.is_dev_teleport_forwards_pressed():
		GameManager.next_checkpoint_teleport(self)
