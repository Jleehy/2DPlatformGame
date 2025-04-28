extends Area2D

@export var speed_boost: int = 500  # Extra speed boost
@export var boost_duration: float = 10.0  # Duration of speed boost in seconds

@onready var sfx_pickup = $sfx_pickup
@onready var collision_shape = $CollisionShape2D  # Added this!

var start_position
var collected = false  # New flag to prevent multiple pickups

func _ready() -> void:
	start_position = global_position
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if collected:
		return  # Already collected, ignore

	if body is CharacterBody2D and body.has_method("apply_speed_boost"):
		collected = true
		collision_shape.disabled = true
		monitoring = false
		
		body.apply_speed_boost(speed_boost, boost_duration)
		GameManager.display_text = "SUPER SPEED ACTIVATED!"
		GameManager.display_text_timer = 100
		
		sfx_pickup.play()
		
		# Animate pickup
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0, -40), 0.4)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(Callable(self, "_on_fade_complete"))

func _on_fade_complete() -> void:
	position = GameManager.dead_position

func reset_position() -> void:
	position = start_position
	modulate.a = 1.0  # Restore full opacity
	collected = false
	collision_shape.disabled = false
	monitoring = true
