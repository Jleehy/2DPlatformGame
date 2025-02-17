extends Area2D

# Called when another body enters the area
func _on_Area2D_body_entered(body):
	if body.name == "Player":  # Check if the body is the player by name
		GameManager.save_checkpoint(position)

# Example usage
func _ready():
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
