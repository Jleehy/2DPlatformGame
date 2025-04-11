extends Area2D

@export var duration: float = 10.0  # Time in seconds for the double damage to last

@onready var sprite: Sprite2D = $Sprite  # Assuming you have a Sprite2D node for the pickup

# Signal to notify when the pickup is collected
signal double_damage_activated

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called when another body enters the area
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("activate_double_damage"):
		body.activate_double_damage(duration)
		#message
		GameManager.display_text = "Double Damage Activated!"
		GameManager.display_text_timer = 100
		
		queue_free()  # Remove the pickup from the scene after being collected
