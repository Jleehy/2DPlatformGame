extends Area2D

func _ready():
	$AnimatedSprite2D.play()

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.animation = "idle"
