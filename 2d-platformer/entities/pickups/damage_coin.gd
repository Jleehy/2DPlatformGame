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
		activate_double_damage(body)
		queue_free()  # Remove the pickup from the scene after being collected

# Activate double damage for the player
func activate_double_damage(player: Node) -> void:
	if player.has_method("activate_double_damage"):
		# Notify the player to activate double damage
		player.activate_double_damage(true)
		# Wait for the specified duration
		await get_tree().create_timer(duration).timeout
		player.activate_double_damage(false)  # Deactivate double damage
