extends Area2D

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var active_checkpoint: bool = false
var checkpoint_saved: bool = false

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player" and not active_checkpoint:  # Check if the body is the player by name
		if not active_checkpoint:
			#message
			GameManager.display_text = "CHECKPOINT ACHIEVED!"
			GameManager.display_text_timer = 100
			
			#set up data for future checkpoint touches so it does not replay
			active_checkpoint = true
			play_flag_animation()
		
		GameManager.save_checkpoint(Vector2(self.global_position.x, self.global_position.y))
		
	#heal the player whenever they touch this.
	if body.has_method("reset_hearts") and body.name == "Player":
		if body.health != 0:
			body.reset_hearts()
		
# Plays the flag animation sequence
func play_flag_animation() -> void:
	animated_sprite.animation = "flag_out"
	animated_sprite.play()
	await animated_sprite.animation_finished
	animated_sprite.animation = "flag_idle"
	animated_sprite.play()

#set up initial animation and collider rule
func _ready() -> void:
	animated_sprite.animation = "no_flag"
	animated_sprite.play()
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
	
func _process(delta: float) -> void:
	#added cool thing. This automates the process of the dev teleport tool.
	if not checkpoint_saved:
		GameManager.checkpoints_list.append(Vector2(self.global_position.x, self.global_position.y))
		checkpoint_saved = true
	
func ret_pos() -> Vector2:
	#a position function
	return self.global_position
