class_name Plant
extends CharacterBody2D

var bullet_scene: Resource = preload("res://entities/enemies/plant/plant_bullet.tscn")
@export var bullet_speed: int = 50

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

var is_dead: bool = false
var direction: int = -1
var should_shoot: bool = false

func _ready() -> void:
	animated_sprite.play("idle")
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_dead:
		kill_plant()
		body.bounce()

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite.animation == "attack":
		shoot_bullet()

func set_direction(new_direction: int) -> void:
	if new_direction < 0:
		direction = -1
		animated_sprite.flip_h = false
	else:
		direction = 1
		animated_sprite.flip_h = true

func set_shoot(shoot: bool) -> void:
	if should_shoot != shoot:
		should_shoot = shoot
		if should_shoot:
			animated_sprite.play("attack")
		else:
			animated_sprite.play("idle")

func shoot_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.set_direction(direction)
	add_child(bullet)

func kill_plant() -> void:
	print("Plant killed!")
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	queue_free()
