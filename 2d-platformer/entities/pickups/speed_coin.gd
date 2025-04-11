extends Area2D

@export var speed_boost: int = 500  # Extra speed boost
@export var boost_duration: float = 10.0  # Duration of speed boost in seconds

var start_position

func _ready() -> void:
	start_position = global_position
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("apply_speed_boost"):
		body.apply_speed_boost(speed_boost, boost_duration)
		#message
		GameManager.display_text = "Super Speed Activated!"
		GameManager.display_text_timer = 100
		
		#allow respawns, so these can be used in puzzles
		position = GameManager.dead_position

func reset_position() -> void:
	#resets the player's position upon the player's death.
	position = start_position
