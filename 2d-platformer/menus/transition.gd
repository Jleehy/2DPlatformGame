extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: RichTextLabel = $AnimationPlayer/UI/Title 

# Connect to triggers
func _ready() -> void:
	#hide()
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

# Function to play fade_in animation with optional custom text
func fade_in(custom_text: String = "YOU DIED") -> void:
	set_title_text("[center]" + custom_text + "[/center]")
	show()
	GameManager.is_transitioning = true
	animation_player.play("fade_in")

#fade in "instantly"
func show_instant(custom_text: String = "YOU DIED") -> void:
	set_title_text("[center]" + custom_text + "[/center]")
	show()
	GameManager.is_transitioning = true
	animation_player.play("fade_in", -1, 999999)

# Function to play fade_out animation
func fade_out() -> void:
	print("Starting fade_out animation, setting is_transitioning = true")
	animation_player.play("fade_out")
	
# Function to change the title text
func set_title_text(new_text: String) -> void:
	title_label.text = new_text

# Connect animation finished signal if you want to hide after fade_out
func _on_animation_player_animation_finished(anim_name: String) -> void:
	print("Animation finished: " + anim_name)
	if anim_name == "fade_out":
		print("here")
		GameManager.is_transitioning = false
		self.visible = false
