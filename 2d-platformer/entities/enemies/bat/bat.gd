extends CharacterBody2D

@export var speed: int = 100
@export var patrol: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

var is_dead: bool = false
var start_position: Vector2

func _ready() -> void:
	start_position = position
	velocity = Vector2(-speed, 0)
	animated_sprite.play("flying")
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _process(delta: float) -> void:
	if is_dead:
		return

	if velocity.x != 0:
		if position.x > start_position.x:
			position.x = start_position.x
			velocity.x = 0
			velocity.y = -speed
			animated_sprite.flip_h = false
		elif position.x <= start_position.x - patrol.x:
			position.x = start_position.x - patrol.x
			velocity.x = 0
			velocity.y = speed
	elif velocity.y != 0:
		if position.y > start_position.y + patrol.y:
			position.y = start_position.y + patrol.y
			velocity.x = speed
			velocity.y = 0
			animated_sprite.flip_h = true
		elif position.y <= start_position.y:
			position.y = start_position.y
			velocity.x = -speed
			velocity.y = 0

	move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider().is_in_group("player"):
			collider.get_collider().take_damage()

func _on_hit_area_body_entered(body: Node):
	if body.is_in_group("player") and not is_dead:
		kill_bat()
		body.bounce()

func kill_bat() -> void:
	print("Bat killed!")
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	await get_tree().create_timer(0.5).timeout
	queue_free()
