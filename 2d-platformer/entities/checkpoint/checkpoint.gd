extends Area2D

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var active_checkpoint: bool = false

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player" and not active_checkpoint:  # Check if the body is the player by name
		active_checkpoint = true
		GameManager.save_checkpoint(position)
		play_flag_animation()
		
		# Uncomment the lines below to transition to Level2 after reaching the first checkpoint.
		# GameManager.player_progress = Vector2.ZERO
		# GameManager.respawn_player(body)
		# GameManager.initialize_level("level_2")

# Plays the flag animation sequence
func play_flag_animation() -> void:
	animated_sprite.animation = "flag_out"
	animated_sprite.play()
	await animated_sprite.animation_finished
	animated_sprite.animation = "flag_idle"
	animated_sprite.play()

# Example usage
func _ready() -> void:
	animated_sprite.animation = "no_flag"
	animated_sprite.play()
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
