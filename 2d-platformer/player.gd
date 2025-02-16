extends CharacterBody2D

@export var speed = 600
@export var jump_speed = -1200
@export var gravity = 4000

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	# Reset the x velocity to 0 so the player
	# only moves while holding the A or D key.
	velocity.x = 0

	# Move the player if the A or D key is being
	# held.
	if Input.is_action_pressed("move_left"):
		velocity.x = -1 * speed
	if Input.is_action_pressed("move_right"):
		velocity.x = speed

	# Update the player animation based on
	# current velocity.
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if is_on_floor():
			$AnimatedSprite2D.animation = "run"
		else:
			if velocity.y < 0:
				$AnimatedSprite2D.animation = "jump"
			else:
				$AnimatedSprite2D.animation = "fall"
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.animation = "idle"

	# Apply gravity.
	velocity.y += gravity * delta

	# Move the player.
	move_and_slide()

	# Add jump force if the jump button is
	# pressed and the player is on the floor.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
