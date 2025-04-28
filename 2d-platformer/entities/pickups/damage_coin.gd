extends Area2D

@export var duration: float = 10.0  # Time in seconds for the double damage to last

@onready var sprite: Sprite2D = $Sprite  # Assuming you have a Sprite2D node for the pickup
@onready var sfx_pickup = $sfx_pickup
@onready var collision_shape = $CollisionShape2D  # Added this!

var start_position
var collected = false  # New flag to prevent double pickups

signal double_damage_activated

func _ready() -> void:
	start_position = global_position
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if collected:
		return  # Already collected, skip

	if body is CharacterBody2D and body.has_method("activate_double_damage"):
		collected = true  # Mark as collected
		collision_shape.disabled = true
		monitoring = false
		
		body.activate_double_damage(duration)
		GameManager.display_text = "DOUBLE DAMAGE ACTIVATED!"
		GameManager.display_text_timer = 100
		
		sfx_pickup.play()
		
		# Animate pickup
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0, -40), 0.4)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(Callable(self, "_on_fade_complete"))

func _on_fade_complete() -> void:
	# When animation is complete, move to dead position
	position = GameManager.dead_position

func reset_position() -> void:
	# Resets the pickup after player death
	position = start_position
	modulate.a = 1.0  # Restore full opacity
	collected = false
	collision_shape.disabled = false
	monitoring = true
