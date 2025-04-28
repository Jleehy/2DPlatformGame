extends Control

@onready var input_manager: InputManager = InputManager  # Accessing AutoLoad Singleton
@onready var game_manager: GameManager = GameManager
var is_paused: bool = false

#set up data fior pause menu
func _ready() -> void: 
	hide()
	set_process_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS

#show up whenever pause is pressed.
func _input(event):
	if InputManager.is_pause_pressed():
		print("pause pressed")
		get_tree().paused = true
		show()

#function to cloase the pause menu
func _on_resume_pressed() -> void:
	print("resume pressed")
	hide()
	get_tree().paused = false

#return to the main menu when it is pressed.
func _on_main_menu_pressed() -> void:
	print("main menu pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
