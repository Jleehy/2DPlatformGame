extends Control

@onready var input_manager: InputManager = InputManager  # Accessing AutoLoad Singleton
@onready var game_manager: GameManager = GameManager
#@onready var input_manager: InputManager = get_node("res://globals/InputManager.gd")  # Adjust the path to your InputManager node
var is_paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	hide()
	set_process_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if InputManager.is_pause_pressed():
		print("pause pressed")
		get_tree().paused = true
		show()


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
