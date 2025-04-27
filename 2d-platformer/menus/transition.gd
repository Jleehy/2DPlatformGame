extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Function to play fade_in animation
func fade_in() -> void:
	show()
	animation_player.play("fade_in")

# Function to play fade_out animation
func fade_out() -> void:
	animation_player.play("fade_out")

# Connect animation finished signal if you want to hide after fade_out
func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		self.visible = false
