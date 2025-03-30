class_name Plant
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

var is_dead: bool = false
var direction: int = -1

func _ready() -> void:
	animated_sprite.play("idle")
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _process(delta: float) -> void:
	if is_dead:
		return

func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_dead:
		kill_plant()
		body.bounce()

func set_direction(new_direction: int) -> void:
	if new_direction < 0:
		direction = -1
		animated_sprite.flip_h = false
	else:
		direction = 1
		animated_sprite.flip_h = true

func kill_plant() -> void:
	print("Plant killed!")
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	queue_free()
