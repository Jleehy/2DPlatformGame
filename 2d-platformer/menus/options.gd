extends Control

@onready var sound_button = $Buttons/Sound  # Reference to Sound Button
@onready var icon = $Buttons/Sound/TextureRect  # Reference to TextureRect
var muted: bool = false
#var WASD: bool = true
var WASD: bool 
var sound_on_icon = preload("res://art/menu/buttons/Volume.png")
var sound_off_icon = preload("res://art/menu/buttons/VolumeMuted.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var events = InputMap.action_get_events("move_left")
	for event in events:
		if event is InputEventKey:
			print("Keycode for move_left:", event.keycode)
			print("Is KEY_A?", event.keycode == KEY_A)
	WASD = is_using_wasd()
	print("WASD =", WASD)
	#WASD = is_using_wasd()
	#print(WASD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.display_text_timer > 0:
		GameManager.display_text_timer -= 1
		if GameManager.display_text_timer <= 0:
			GameManager.display_text = ""

func is_using_wasd() -> bool:
	var events = InputMap.action_get_events("move_left")
	for event in events:
		if event is InputEventKey and (event.keycode == KEY_A or event.keycode == 0):
			return true
	return false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_sound_pressed() -> void:
	if muted:
		icon.texture = sound_on_icon
		muted = false
	else:
		icon.texture = sound_off_icon
		muted = true


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/help.tscn")


func _on_keybind_pressed() -> void:
	InputMap.action_erase_events("move_left")
	InputMap.action_erase_events("move_right")
	InputMap.action_erase_events("crouch")
	if WASD:
		var left_event = InputEventKey.new()
		left_event.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", left_event)

		var right_event = InputEventKey.new()
		right_event.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", right_event)


		var down_event = InputEventKey.new()
		down_event.keycode = KEY_DOWN
		InputMap.action_add_event("crouch", down_event)

		WASD = false
		print("wasd off")
		GameManager.display_text = "WASD is OFF"
	else:
		var left_event = InputEventKey.new()
		left_event.keycode = KEY_A
		InputMap.action_add_event("move_left", left_event)

		var right_event = InputEventKey.new()
		right_event.keycode = KEY_D
		InputMap.action_add_event("move_right", right_event)

		var down_event = InputEventKey.new()
		down_event.keycode = KEY_S
		InputMap.action_add_event("crouch", down_event)
		WASD = true
		print("wasd on")
		GameManager.display_text = "WASD is ON"
	GameManager.display_text_timer = 100
