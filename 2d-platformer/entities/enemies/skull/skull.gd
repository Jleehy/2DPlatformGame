class_name Skull
extends CharacterBody2D

var bullet_scene: Resource = preload("res://entities/enemies/plant/plant_bullet.tscn")

@export var max_health:int = 5      # Skull's health
@export var speed:int = 150         # Skull's Speed
@export var chase_radius:int = 150  # Radius where the Skull will chase the Player
@export var shot_radius:int = 500   # Radius where the Skull will shoot at the Player

var player_reference:CharacterBody2D  # Player object
var current_health:int                # Skull's current health
var start_position:Vector2            # Skull's start position
var shoot:bool = false                # Whether the Skull should shoot
var recenter:bool = false             # Whether the Skull should recenter itself
var is_dead:bool = false              # Whether the Skull is dead

func _ready() -> void:
	# Initialize the Skull
	current_health = max_health
	start_position = position
	$AnimatedSprite2D.play("idle_ranged")


func _process(delta:float) -> void:
	# Calculate the Skull's distance from its center and to the Player
	var distance_to_player = position.distance_to(player_reference.position)
	var distance_to_center = position.distance_to(start_position)

	if distance_to_player < chase_radius and distance_to_center < chase_radius and !recenter:
		# If the Player is inside the chase radius, the Skull hasn't moved too far from the
		# center, and the Skull is not recentering, chase the player.
		shoot = false
		velocity.x = speed * (player_reference.position.x - position.x) / distance_to_player
		velocity.y = speed * (player_reference.position.y - position.y) / distance_to_player
		if $AnimatedSprite2D.animation == "idle_ranged":
			$AnimatedSprite2D.play("idle_melee")
	elif distance_to_player < shot_radius and !recenter:
		# If the Player is inside the shot radius and the Skull is not recentering, shoot at
		# the Player.
		shoot = true
	elif distance_to_center > speed / 20:
		# If the skull is too far from the starting position, move back.
		shoot = false
		recenter = true
		velocity.x = speed * (start_position.x - position.x) / distance_to_center
		velocity.y = speed * (start_position.y - position.y) / distance_to_center
		if $AnimatedSprite2D.animation == "idle_melee":
			$AnimatedSprite2D.play("idle_ranged")
	else:
		# Sit and wait at the starting position.
		recenter = false
		velocity = Vector2.ZERO

	move_and_slide()

	# Deal damage to the Player on contact.
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider().is_in_group("player"):
			collider.get_collider().take_damage(1)


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		current_health -= 1
		body.bounce()

		if $AnimatedSprite2D.animation == "idle_melee":
			# Recenter the Skull if the Player deals damage.
			$AnimatedSprite2D.play("hit_melee")
			recenter = true

		if $AnimatedSprite2D.animation == "idle_ranged":
			$AnimatedSprite2D.play("hit_ranged")

		if current_health == 0:
			print("Skull Killed!")
			is_dead = true
			$CollisionShape2D.set_deferred("disabled", true)
			await get_tree().create_timer(0.5).timeout
			queue_free()


func _on_animated_sprite_2d_animation_looped() -> void:
	if $AnimatedSprite2D.animation == "idle_ranged" and shoot and !recenter:
		# Shoot a bullet at the Player.
		var bullet:Variant = bullet_scene.instantiate()
		var x_dir:float = (player_reference.position.x - position.x) / position.distance_to(player_reference.position)
		var y_dir:float = (player_reference.position.y - position.y) / position.distance_to(player_reference.position)
		bullet.set_direction(Vector2(x_dir, y_dir))
		add_child(bullet)
	if $AnimatedSprite2D.animation == "hit_melee" or $AnimatedSprite2D.animation == "hit_ranged":
		# Switch to the idle ranged animation after a hit animation.
		$AnimatedSprite2D.animation = "idle_ranged"


func attach_player(player:CharacterBody2D) -> void:
	player_reference = player
