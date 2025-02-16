extends CharacterBody2D

@export var speed = 600
@export var jump_speed = -1200
@export var gravity = 4000

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_left"):
		velocity.x = -1 * speed
	if Input.is_action_pressed("move_right"):
		velocity.x = speed

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.animation = "idle"

	velocity.y += gravity * delta
	move_and_slide()

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
