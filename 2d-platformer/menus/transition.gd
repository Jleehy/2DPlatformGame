extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

# Function to play fade_in animation
func fade_in() -> void:
	show()
	GameManager.is_transitioning = true
	animation_player.play("fade_in")

# Function to play fade_out animation
func fade_out() -> void:
	print("Starting fade_out animation, setting is_transitioning = true")
	animation_player.play("fade_out")
	#GameManager.is_transitioning = false

# Connect animation finished signal if you want to hide after fade_out
func _on_animation_player_animation_finished(anim_name: String) -> void:
	print("Animation finished: " + anim_name)
	if anim_name == "fade_out":
		print("here")
		GameManager.is_transitioning = false
		self.visible = false
