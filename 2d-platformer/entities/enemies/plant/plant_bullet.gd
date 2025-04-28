extends Area2D

var speed:int = 150
var direction:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	#move across the screen each frame
	position.x += speed * direction.x * delta
	position.y += speed * direction.y * delta

func set_direction(new_direction: Vector2) -> void:
	#used when bullet first shot
	direction = new_direction
	position.x += 25 * direction.x
	position.y += 25 * direction.y

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#when offscreen, delete this.
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	#damage the player if they touch this.
	if is_instance_of(body, Player):
		body.take_damage(1)
		queue_free()
	if is_instance_of(body, Skull) or is_instance_of(body, Plant):
		pass
		#do nothing and just pass through the bullet-shooters themselves.
	else:
		queue_free()
		
func despawn() -> void:
	#the function called when the player dies, to despawn all things
	#like the bullets
	queue_free()
