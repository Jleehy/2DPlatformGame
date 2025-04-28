extends CharacterBody2D

# Enemy variables
@export var gravity: int = 1500
@export var TELEPORT_RANGE_MAX: int = 300
@export var TELEPORT_RATE: int = 400

# Health variables
@export var max_health: int = 1000  # Number of hits required to defeat the enemy
var current_health: int
var redval: float

# Animation variables
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var kill_zone: Area2D = $KillZone  # Reference to the Area2D node

@onready var sfx_hurt = $sfx_hurt

# State variables
var is_dead: bool = false
var starting_position: Vector2
var can_hurt_player: bool = true  # Cooldown to prevent rapid damage to the player

func _ready() -> void:
	#set up initial data about this enemy
	starting_position = position
	current_health = max_health  # Set health to max
	redval = 0
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Stop processing if the enemy is dead

	#apply normal functions each frame.
	apply_gravity(delta)
	handle_movement()
	move_and_slide()

	# Check if the player is colliding with the enemy (for hurting the player)
	check_player_collision()
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func handle_movement() -> void:
	if not is_dead:
		#handle the teleporting.
		if GameManager.enemy_timer_current % TELEPORT_RATE == 0:
			#teleport periodically.
			var displacement = Vector2(randi() % (TELEPORT_RANGE_MAX * 2) - TELEPORT_RANGE_MAX, randi() % (TELEPORT_RANGE_MAX * 2) - TELEPORT_RANGE_MAX)
			position = starting_position + displacement
			
		if GameManager.enemy_timer_current % TELEPORT_RATE > TELEPORT_RATE * 0.8:
			modulate.r = 1.0 - (GameManager.enemy_timer_current % TELEPORT_RATE - (TELEPORT_RATE * 0.8)) / (TELEPORT_RATE * 0.4)
			
		else:
			modulate.r = 1
			
	else:
		pass

func check_player_collision() -> void:
	#damage the player as is needed
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player") and can_hurt_player:
			hurt_player(collision.get_collider())
			#teleport on hit so no trapping the player
			var displacement = Vector2(randi() % (TELEPORT_RANGE_MAX * 2) - TELEPORT_RANGE_MAX, randi() % (TELEPORT_RANGE_MAX * 2) - TELEPORT_RANGE_MAX)
			position = starting_position + displacement

func _on_kill_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_dead:
		take_damage(body)  # Pass the player to the take_damage function
		body.bounce(true)  # Make the player bounce after hitting the enemy

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
		kill_stoneman()
	else:
		#animated_sprite.play("hurt")  # Play hurt animation if available
		pass

func kill_stoneman() -> void:
	print("Enemy defeated!")
	is_dead = true
	velocity = Vector2.ZERO  # Stop movement
	collision_shape.set_deferred("disabled", true)  # Disable collision
	#animated_sprite.play("hit")
	
	#message
	GameManager.display_text = "DEFEATED STONEMAN!"
	GameManager.display_text_timer = 100
	
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
