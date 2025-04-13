class_name Skull
extends CharacterBody2D

var bullet_scene: Resource = preload("res://entities/enemies/plant/plant_bullet.tscn")

@export var max_health:int = 5
@export var speed:int = 150
@export var shot_speed:int = 100
@export var chase_radius:int = 150
@export var shot_radius:int = 300

var player_reference:CharacterBody2D
var current_health:int
var start_position:Vector2
var shoot:bool = false
var recenter:bool = false
var is_dead:bool = false

func _ready() -> void:
	current_health = max_health
	start_position = position
	velocity = Vector2(speed, 0)
	$AnimatedSprite2D.play("idle_ranged")


func _process(delta:float) -> void:
	var distance_to_player = position.distance_to(player_reference.position)
	var distance_to_center = position.distance_to(start_position)
	if distance_to_player < chase_radius and distance_to_center < chase_radius and !recenter:
		shoot = false
		velocity.x = speed * (player_reference.position.x - position.x) / distance_to_player
		velocity.y = speed * (player_reference.position.y - position.y) / distance_to_player
		if $AnimatedSprite2D.animation == "idle_ranged":
			$AnimatedSprite2D.play("idle_melee")
	elif distance_to_player < shot_radius and !recenter:
		shoot = true
	elif distance_to_center > speed / 20:
		shoot = false
		recenter = true
		velocity.x = speed * (start_position.x - position.x) / distance_to_center
		velocity.y = speed * (start_position.y - position.y) / distance_to_center
		if $AnimatedSprite2D.animation == "idle_melee":
			$AnimatedSprite2D.play("idle_ranged")
	else:
		recenter = false
		velocity = Vector2.ZERO

	move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider().is_in_group("player"):
			collider.get_collider().take_damage(1)


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		current_health -= 1
		body.bounce()

		if $AnimatedSprite2D.animation == "idle_melee":
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
		var bullet:Variant = bullet_scene.instantiate()
		var x_dir:float = (player_reference.position.x - position.x) / position.distance_to(player_reference.position)
		var y_dir:float = (player_reference.position.y - position.y) / position.distance_to(player_reference.position)
		bullet.set_direction(Vector2(x_dir, y_dir))
		add_child(bullet)
	if $AnimatedSprite2D.animation == "hit_melee" or $AnimatedSprite2D.animation == "hit_ranged":
		$AnimatedSprite2D.animation = "idle_ranged"


func attach_player(player:CharacterBody2D) -> void:
	player_reference = player
