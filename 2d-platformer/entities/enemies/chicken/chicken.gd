extends CharacterBody2D

# Enemy variables
@export var speed: int = 100
@export var gravity: int = 2000
@export var patrol_distance: int = 100  # How far the enemy patrols before turning around

# Health variables
@export var max_health: int = 3  # Number of hits required to defeat the enemy
var current_health: int
var redval: float

# Animation variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var kill_zone: Area2D = $KillZone  # Reference to the Area2D node

# State variables
var is_dead: bool = false
var direction: int = -1  # -1 for left, 1 for right
var starting_position: Vector2
var can_hurt_player: bool = true  # Cooldown to prevent rapid damage to the player

func _ready() -> void:
	starting_position = position
	current_health = max_health  # Set health to max
	redval = 0
	animated_sprite.play("idle")
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Stop processing if the enemy is dead

	apply_gravity(delta)
	handle_movement()
	handle_animation()
	move_and_slide()

	# Check if the player is colliding with the enemy (for hurting the player)
	check_player_collision()
	
	flash_red_show_hp()
	
func flash_red_show_hp() -> void:
	#this is a function to make the enemy flash with a frequency
	#proportional to their ratio of max HP to their missing HP
	#if they are missing any HP. This is to make enemies communicvate this information
	#to the player.
	var missing_hp = max_health - current_health
	var missable_hp = max_health - 1
	
	var cur_timer = GameManager.enemy_timer_current
	
	if missing_hp == 0 or current_health == 0:
		redval = 0.0
	
	elif (cur_timer % int((100 * ((1.0 * current_health) / (1.0 * max_health)))) <= 15) and (redval <= 0.001):
		#see if the enemy should be currently flashing
		redval = 0.1
	
	elif (cur_timer % int((100 * ((1.0 * current_health) / (1.0 * max_health)))) <= 15):
		redval *= 1.5
	
	else:
		redval = 0.0
		
	var temp_num = 1 - redval
	
	if temp_num >= 1:
		temp_num = 1
	elif temp_num <= 0:
		temp_num = 0
		
	modulate = Color(1, temp_num, temp_num, 1)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func handle_movement() -> void:
	if is_on_floor() and not is_dead:
		# Simple patrol logic
		if patrol_distance > 0:
			if abs(position.x - starting_position.x) >= patrol_distance:
				direction *= -1  # Reverse direction
				starting_position = position  # Reset start position

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
		take_damage(body)  # Pass the player to the take_damage function
		body.bounce()  # Make the player bounce after hitting the enemy

# Modified take_damage() function
func take_damage(player: Node) -> void:
	# If the player has double_damage enabled, the enemy will take instant damage
	if player.double_damage:
		print("Double damage!")
		current_health -= 2
		print("Enemy hit! Health left:", current_health)
	else:
		current_health -= 1  # Normal damage
		print("Enemy hit! Health left:", current_health)

	if current_health <= 0:
		kill_chicken()
	else:
		animated_sprite.play("hurt")  # Play hurt animation if available

func kill_chicken() -> void:
	print("Enemy defeated!")
	is_dead = true
	velocity = Vector2.ZERO  # Stop movement
	collision_shape.set_deferred("disabled", true)  # Disable collision
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout  # Wait for animation to finish
	#OK!
	#We cannot have the thing be removed, as it must be able to be resummoned later
	#so teleport it to the dead realm, far away
	#it will come back if revived.
	position = GameManager.dead_position

func hurt_player(player: Node) -> void:
	if not is_dead:
		player.take_damage(1)  # Call a method on the player to handle damage
		
		# Cooldown to prevent rapid damage
		can_hurt_player = false
		await get_tree().create_timer(0.5).timeout  # Cooldown before hurting again
		can_hurt_player = true

func heal_and_respawn() -> void:
	#does what it says. caLLed by gamemanager on player death.
	current_health = max_health
	position = starting_position
	is_dead = false
	collision_shape.set_deferred("disabled", false)
