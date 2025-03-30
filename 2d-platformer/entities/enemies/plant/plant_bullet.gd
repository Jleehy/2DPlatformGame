extends Area2D

var speed: int = 150
var direction: int

func _process(delta: float) -> void:
	position.x += speed * direction * delta

func set_direction(new_direction: int) -> void:
	direction = -1 if new_direction < 0 else 1
	position.x += 25 * direction

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		body.take_damage()
		queue_free()
