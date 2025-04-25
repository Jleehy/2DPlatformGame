extends Area2D

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var active_checkpoint: bool = false
var checkpoint_saved: bool = false

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player" and not active_checkpoint:  # Check if the body is the player by name
		if not active_checkpoint:
			active_checkpoint = true
			play_flag_animation()
		
		GameManager.save_checkpoint(Vector2(global_position.x, global_position.y))
		
	if body.has_method("reset_hearts") and body.name == "Player":
		if body.health != 0:
			body.reset_hearts()
		
# Plays the flag animation sequence
func play_flag_animation() -> void:
	animated_sprite.animation = "moving"
	animated_sprite.play()
	await animated_sprite.animation_finished
	animated_sprite.animation = "idle"
	animated_sprite.play()

# Example usage
func _ready() -> void:
	animated_sprite.animation = "idle"
	animated_sprite.play()
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not checkpoint_saved:
		GameManager.checkpoints_list.append(Vector2(self.global_position.x, self.global_position.y))
		checkpoint_saved = true
		GameManager.player_progress = global_position
	
func ret_pos() -> Vector2:
	return self.global_position
