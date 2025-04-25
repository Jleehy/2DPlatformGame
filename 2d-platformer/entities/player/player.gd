class_name Player
extends CharacterBody2D

@onready var jump_particles = $JumpParticles
@onready var land_particles = $LandingParticles
@onready var movement_ghost = $MovementGhost

var was_on_floor: bool = false  # Track if the player was on the floor last frame

# Player physics variables
@export var speed: int = 400
@export var crouch_fall_speed: int = 400
@export var jump_speed: int = -1050

# Sound effects
@onready var sfx_dash = $sfx_dash
@onready var sfx_jump  = $sfx_jump
@onready var sfx_death  = $sfx_death
@onready var sfx_hurt  = $sfx_hurt
@onready var sfx_land  = $sfx_land

# Advanced physics variables
@export var minimum_speed_percentage: float = 0.25
@export var player_input_acceleration_percent: float = 0.5
@export var friction_value: float = 0.6
@export var air_control_loss: float = 0.2
@export var facing_direction: String = "left"
@export var step_height: float = 0.75

# Crouching variables
@export var crouch_speed_reduction: float = 0.50
@export var is_crouching: bool = false
@export var original_collision_size: Vector2
@export var crouch_squish_amount: float = 0.75
@export var crouch_used: bool = false

# Dash and other Movement variables
@export var dash_speed: float = 1500
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 0.5
@export var dash_unlocked: bool = false
var is_dashing: bool = false
var can_dash: bool = true

@export var death_timer: int = -1

# Animation variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Hurt state
var is_hurt: bool = false
var can_take_damage: bool = true  # Not used now since cooldown is via damage_cooldown_timer

# --- Heart Damage System Variables ---
var hearts_list: Array[TextureRect] = []
@export var health: int = 3
@export var block_heart_display: bool = false

# --- Damage Cooldown Tracking ---
var damage_cooldown_timer: float = 2.0   # starts at 2 seconds so damage is allowed immediately
const DAMAGE_COOLDOWN: float = 2.0         # 2 seconds cooldown

# Grapple Stuff
@export var can_grapple: bool = true
@export var grapple_length: int = 150
var is_grappling: bool = false
var grapple_line_exists: bool = false
var grapple_progress: int = 0
var found_grapple_hold: int = false
var grapple_line: Line2D = null
var raycast: RayCast2D = null
@export var grapple_unlocked: bool = false

signal player_died
signal player_respawned

func _ready() -> void:
	animated_sprite.play()
	GameManager.save_checkpoint(self.position)
	original_collision_size = collision_shape.shape.size
	
	# Initialize heart icons from a health bar (assumes a node at "$health_bar/HBoxContainer")
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print("Hearts List:", hearts_list)

# Damage cooldown and invulnerability variables
var invuln_timer: float = 0.0              # additional invulnerability timer
const INVULNERABILITY_DURATION: float = 0.5  # 0.5 seconds of invulnerability after respawn

func _physics_process(delta: float) -> void:
	# Update the damage cooldown timer each frame.
	damage_cooldown_timer = min(damage_cooldown_timer + delta, DAMAGE_COOLDOWN)
	
	# Update the invulnerability timer, if active.
	if invuln_timer > 0:
		invuln_timer = max(invuln_timer - delta, 0)
	
	if is_on_floor() and not was_on_floor:
		#sfx_land.play()
		land_particles.restart()
		land_particles.emitting = true
		crouch_used = false
	
	# Update was_on_floor for next frame
	was_on_floor = is_on_floor()
	
	if death_timer == -1:
		if not is_dashing:
			apply_gravity(delta)
		#reset the grapple/dash being allowed to be used
		if (not can_grapple) and grapple_unlocked and is_on_floor():
			can_grapple = true
		if (not can_dash) and dash_unlocked and is_on_floor():
			can_dash = true
		handle_crouching()
		handle_movement()
		handle_grapple()
		handle_jumping()
		handle_dash()
		handle_player_dash_and_grapple_coloration()
		handle_level_bounds()
		update_animation()
		move_and_slide()
		climb_ledges()
		handle_self_die()
		update_heart_display()
		dev_checkpoint_handle()
	else:
		handle_death_animation()

func apply_gravity(delta: float) -> void:
	var gravity = GameManager.get_gravity()
	
	if is_grappling:
		return
		#dont mess with the grapple physics
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
		if velocity.y >= GameManager.get_terminal_velocity():
			velocity.y = GameManager.get_terminal_velocity()
		
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
	if is_grappling:
		return
		#no facing change while grappling
		
	if InputManager.is_move_left_pressed():
		velocity.x += -speed * control_factor * player_input_acceleration_percent
		movement_ghost.scale.x = -1
		facing_direction = "left"
	if InputManager.is_move_right_pressed():
		velocity.x += speed * control_factor * player_input_acceleration_percent
		movement_ghost.scale.x = 1
		facing_direction = "right"

func handle_jumping() -> void:
	if InputManager.is_jump_pressed() and is_on_floor():
		sfx_jump.play()
		jump_particles.restart()
		jump_particles.emitting = true
		velocity.y = jump_speed
		
func handle_grapple() -> void:
	if grapple_progress == 0:
		#if the grapple line exists, delete it
		if grapple_line_exists:
			grapple_line_exists = false
			delete_grapple_line()
	
	if ((not can_grapple) and (not is_grappling)) or (not grapple_unlocked) or (is_dashing):
		return
	
	if InputManager.is_grapple_pressed() and not is_grappling:
		#if the line does not exist, create it
		if not grapple_line_exists:
			create_grapple_line()
			grapple_line_exists = true
			
		#set up the grapple progress and other variables
		grapple_progress = 0
		is_grappling = true
		found_grapple_hold = false
		velocity = Vector2(0,-25)
	
	elif is_grappling and found_grapple_hold:
		#grapple hold gotten, so now begin pulling player towards it.
		#if the line does not exist, create it
		if not grapple_line_exists:
			create_grapple_line()
			grapple_line_exists = true
			
		grapple_progress -= 6
		if grapple_progress < 0:
			#minimum progress check
			grapple_progress = 0
		
		var facing_factor = int(facing_direction == "right") * 2 - 1
		grapple_line.points = [Vector2(facing_factor * 3,-1), Vector2(grapple_progress * facing_factor, -1 * grapple_progress)]
		
		#hold the player in midair
		velocity = Vector2(0,0)	
		
		#move the player with position, to ensure the grapple actually pulls them.
		position = Vector2(position.x + 10 * facing_factor, position.y - 10)
		
		#if at 0, then stop the grapple
		if grapple_progress == 0:
			#give the player a little boost.
			velocity = Vector2(0, jump_speed)
			is_grappling = false
			can_grapple = false
	
	elif is_grappling and grapple_progress >= 0:
		#if the line does not exist, create it
		if not grapple_line_exists:
			create_grapple_line()
			grapple_line_exists = true
			
		#increment the progress, then move the line to match up with the player
		grapple_progress += 5
		var facing_factor = int(facing_direction == "right") * 2 - 1
		grapple_line.points = [Vector2(facing_factor * 3,-1), Vector2(grapple_progress * facing_factor, -1 * grapple_progress)]

		#if enough time passed, grapple over, being fast retraction
		if grapple_progress >= grapple_length:
			grapple_progress = int(grapple_length * -0.15)		
			
		#hold the player in midair
		velocity = Vector2(0,-25)	
		
		#check if you hit a wall
		raycast.target_position = grapple_line.points[1]
		raycast.force_raycast_update()
		if raycast.is_colliding():
			#we hit a thing!
			found_grapple_hold = true
		
	elif is_grappling:
		#if the line does not exist, create it
		if not grapple_line_exists:
			create_grapple_line()
			grapple_line_exists = true
			
		#use the negative value of progress as a mini fast timer to retreact the grapple
		grapple_progress += 1
		
		#draw the line retracting
		var facing_factor = int(facing_direction == "right") * 2 - 1
		grapple_line.points = [Vector2(facing_factor * 3,-1), Vector2((grapple_progress / -0.15) * facing_factor, (grapple_progress / 0.15))]

		#once the progress reaches 0, stop the grapple.
		if grapple_progress == 0:
			is_grappling = false
			can_grapple = false

		#hold the player in midair
		velocity = Vector2(0,20)	
		
		#check if you hit a wall
		raycast.target_position = grapple_line.points[1]
		raycast.force_raycast_update()
		if raycast.is_colliding():
			#we hit a thing!
			found_grapple_hold = true
		
func create_grapple_line() -> void:
	if grapple_line == null:
		grapple_line = Line2D.new()
		grapple_line.width = 3
		grapple_line.default_color = Color(1, 0.75, 0.8)
		grapple_line.points = [GameManager.dead_position, Vector2(GameManager.dead_position.x - 1, GameManager.dead_position.y - 1)]
		grapple_line.z_index = 1
		grapple_line.visible = true
		grapple_line.begin_cap_mode = Line2D.LineCapMode.LINE_CAP_ROUND
		grapple_line.end_cap_mode = Line2D.LineCapMode.LINE_CAP_ROUND
		add_child(grapple_line)
		
		#make the raycast too
		raycast = RayCast2D.new()	
		raycast.enabled = true
		raycast.collide_with_areas = false
		raycast.position = Vector2(0,0)
		add_child(raycast)


func delete_grapple_line() -> void:
	if grapple_line != null:
		grapple_line.queue_free()
		grapple_line = null
		
		raycast.queue_free()
		raycast = null

func handle_dash() -> void:
	if not dash_unlocked:
		return  # Prevent dashing if not unlocked
	if not can_dash:
		pass
		#code that was here moved to other function
	if is_grappling:
		#you are not allowed to start dashing while grappling.
		return
	else:
		pass
		#code that was here moved to other function
		
	if InputManager.is_dash_pressed() and can_dash and not is_dashing:
		sfx_dash.play()
		start_dash()
		
func handle_player_dash_and_grapple_coloration() -> void:
	#first, check if the player can either grapple or dash
	#if not, just set the default color
	#if only 1, then apply the filters only for that color
	#if both, then apply both as needed.
	if (not grapple_unlocked) and (not dash_unlocked):
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
		return
		
	elif (not grapple_unlocked) and dash_unlocked:
		if not can_dash:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.8, 1), 0.1)
		else:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
		return
		
	elif (not dash_unlocked) and grapple_unlocked:
		if not can_grapple:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(0.8, 0.3, 0.3, 1), 0.1)
		else:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
		
		return
		
	elif grapple_unlocked and dash_unlocked:
		if (not can_grapple) and (not can_dash):
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(0.9, 0.1, 0.9, 1), 0.1)
		elif (not can_grapple) and can_dash:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(0.8, 0.3, 0.3, 1), 0.1)
		elif (not can_dash) and can_grapple:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.8, 1), 0.1)
		else:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
			
		return
		
	#you shouldn't ever get to this point
	return

func start_dash() -> void:
	is_dashing = true
	can_dash = false

	# Set dash velocity based on facing direction
	var dash_direction: Vector2 = Vector2.RIGHT if facing_direction == "right" else Vector2.LEFT
	velocity = dash_direction * dash_speed

	# Start dash duration timer
	await get_tree().create_timer(dash_duration).timeout
	end_dash()

	# Start dash cooldown timer
	#removed.

func end_dash() -> void:
	is_dashing = false
	velocity.x = 0

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
	if is_hurt:
		return  # Do not change animation if hurt
	if velocity.x != 0 or velocity.y != 0:
		animated_sprite.flip_h = facing_direction == "left"
		if is_on_floor():
			movement_ghost.emitting = false
			animated_sprite.play("run")
		else:
			if velocity.y < 0:
				movement_ghost.emitting = true
				animated_sprite.play("jump")
			else:
				movement_ghost.emitting = true
				animated_sprite.play("fall")
	else:
		movement_ghost.emitting = false
		animated_sprite.play("idle")

func handle_death_animation() -> void:
	if animated_sprite.rotation_degrees < 90:
		animated_sprite.rotation_degrees += 5
	else:
		animated_sprite.rotation_degrees = 90

	death_timer -= 1
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
	emit_signal("player_died") 
	if death_timer == 0:
		var respawn_timer = get_tree().create_timer(3.0)  
		respawn_timer.timeout.connect(_on_respawn_timer_timeout)  
		
		
func _on_respawn_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
	animated_sprite.rotation_degrees = 0
	reset_hearts() 
	GameManager.respawn_player(self)
	death_timer = -1
	emit_signal("player_respawned") 
	await get_tree().create_timer(2.3).timeout
	block_heart_display = false

func handle_crouching() -> void:
	if InputManager.is_crouch_pressed():
		if not is_crouching and not crouch_used:
			crouch_used = true
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
			
			velocity.y += crouch_fall_speed
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

func bounce() -> void:
	velocity.y = -800 

func take_damage(amount_damage: int) -> void:
	# Do not take damage if we're still in the invulnerability period.
	if invuln_timer > 0:
		return
	# Use the damage cooldown timer to ensure damage is only applied once every 2 seconds.
	if damage_cooldown_timer < DAMAGE_COOLDOWN:
		return
	# Reset the cooldown timer.
	damage_cooldown_timer = 0.0
	
	# Decrement health and update the heart display.
	health -= amount_damage
	
	if health < 0:
		health = 0
		
	if health > 3:
		health = 3
	
	update_heart_display()
	
	# Play the hit animation and enforce a brief hurt state.
	is_hurt = true
	animated_sprite.play("hit")
	sfx_hurt.play()
	await animated_sprite.animation_finished
	is_hurt = false
	
	# If no hearts remain, kill the player immediately.
	if health <= 0:
		GameManager.kill_player(self)
		return
	
# Reset hearts back to full health (3 hearts) upon respawn,
# allow damage again, and grant temporary invulnerability.


func update_heart_display() -> void:
	# Update each heart's visibility based on current health
	for i in range(hearts_list.size()):
		hearts_list[i].visible = (i < health) and (not block_heart_display)

# Reset hearts back to full health (3 hearts) upon respawn and allow damage again
func reset_hearts() -> void:
	health = 3
	update_heart_display()
	damage_cooldown_timer = DAMAGE_COOLDOWN
	is_hurt = false
	invuln_timer = INVULNERABILITY_DURATION

func handle_self_die() -> void:
	if InputManager.is_self_death_pressed():
		GameManager.kill_player(self)

func dev_checkpoint_handle() -> void:
	if InputManager.is_dev_teleport_backwards_pressed():
		GameManager.prev_checkpoint_teleport(self)
		
	if InputManager.is_dev_teleport_forwards_pressed():
		GameManager.next_checkpoint_teleport(self)
		
	if InputManager.is_dev_next_level_pressed():
		for node in get_tree().current_scene.get_children():
			if node.name == "EndPoint":
				position = node.position
				break

func apply_speed_boost(amount: int, duration: float) -> void:
	speed += amount
	await get_tree().create_timer(duration).timeout
	speed -= amount

func player():
	pass

#---------------
var double_damage: bool = false  # Flag to check if double damage is active

# Called when double damage is activated or deactivated
func activate_double_damage(duration: float) -> void:
	double_damage = true
	await get_tree().create_timer(duration).timeout
	double_damage = false

func climb_ledges() -> void:
	#if we notice that now the player is not moving, yet not against a wall, 
	#yet they are pushing in a direction, then we know they hit a wall.
	#move them up then move the player once more
	if (velocity.x == 0 and is_on_wall() and is_on_floor() and damage_cooldown_timer >= DAMAGE_COOLDOWN):
		#for right
		if ((InputManager.is_move_left_pressed() or InputManager.is_move_right_pressed())) and (not InputManager.is_jump_pressed()):
			var climbable = is_wall_climbable()
			if climbable:
				sfx_jump.play()
				jump_particles.restart()
				jump_particles.emitting = true
				velocity.y += jump_speed * step_height
				apply_horizontal_movement(1.0)
			
func is_wall_climbable() -> bool:
	return $ClimbCheckArea.get_overlapping_bodies().size() == 0
			
