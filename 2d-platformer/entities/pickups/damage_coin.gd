extends Area2D

@export var duration: float = 10.0  # Time in seconds for the double damage to last

@onready var sprite: Sprite2D = $Sprite  # Assuming you have a Sprite2D node for the pickup
# Sound effects
@onready var sfx_pickup = $sfx_pickup

var start_position

# Signal to notify when the pickup is collected
signal double_damage_activated

func _ready() -> void:
	start_position = global_position
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called when another body enters the area
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("activate_double_damage"):
		body.activate_double_damage(duration)
		#message
		GameManager.display_text = "DOUBLE DAMAGE ACTIVATED!"
		GameManager.display_text_timer = 100
		print(sfx_pickup)
		sfx_pickup.play()
		
		#allow respawns, so these can be used in puzzles
		position = GameManager.dead_position

func reset_position() -> void:
	#resets the player's position upon the player's death.
	position = start_position
