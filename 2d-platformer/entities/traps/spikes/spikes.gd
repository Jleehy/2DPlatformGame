extends Area2D

@onready var sfx_hurt  = $sfx_hurt

# Called when another body enters the area
func _on_Area2D_body_entered(body):
	if body.name == "Player":  # Check if the body is the player by name
		sfx_hurt.play()
		GameManager.kill_player(body)

# Example usage
func _ready():
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
