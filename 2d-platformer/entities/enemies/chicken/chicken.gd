extends CharacterBody2D

# Enemy variables
@export var speed: int = 100
@export var gravity: int = 2000
@export var patrol_distance: int = 100  # How far the chicken patrols before turning around

# Animation variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var kill_zone: Area2D = $KillZone  # Reference to the Area2D node

# State variables
var is_dead: bool = false
var direction: int = -1  # -1 for left, 1 for right
var start_position: Vector2
var can_hurt_player: bool = true  # Cooldown to prevent rapid damage to the player

func _ready() -> void:
	start_position = position
	animated_sprite.play("idle")
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Stop processing if the chicken is dead

	apply_gravity(delta)
	handle_movement()
	handle_animation()
	move_and_slide()

	# Check if the player is colliding with the chicken (for hurting the player)
	check_player_collision()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func handle_movement() -> void:
	if is_on_floor() and not is_dead:
		# Simple patrol logic
		if patrol_distance > 0:
			if abs(position.x - start_position.x) >= patrol_distance:
				direction *= -1  # Reverse direction
				start_position = position  # Reset start position

			velocity.x = direction * speed
	else:
		velocity.x = 0  # Stop moving if dead or in the air

func handle_animation() -> void:
	if is_dead:
		animated_sprite.play("hit")
	elif velocity.x != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = direction == 1  # Flip sprite based on direction
	else:
		animated_sprite.play("idle")

func check_player_collision() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player") and can_hurt_player:
			hurt_player(collision.get_collider())

func _on_kill_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_dead:
		kill_chicken()
		body.bounce()  # Make the player bounce after killing the chicken

func kill_chicken() -> void:
	print("Chicken killed!")
	is_dead = true
	velocity = Vector2.ZERO  # Stop movement
	collision_shape.set_deferred("disabled", true)  # Disable collision
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout  # Wait for animation to finish
	queue_free()  # Remove the chicken from the scene

func hurt_player(player: Node) -> void:
	if not is_dead:
		player.take_damage()  # Call a method on the player to handle damage
		
		# Cooldown to prevent rapid damage
		can_hurt_player = false
		await get_tree().create_timer(0.5).timeout  # Cooldown before hurting again
		can_hurt_player = true
