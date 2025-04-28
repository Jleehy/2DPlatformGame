extends Control
@onready var player: Node = $Player

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

#add the correct menu as needed
func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

#add the correct menu as needed
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

#add the correct menu as needed
func _on_level_2_pressed() -> void:
	if GameManager.level2_unlocked:
		get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
	else:
		print("Level 2 is locked!")

#add the correct menu as needed
func _on_level_3_pressed() -> void:
	if GameManager.level2_unlocked:
		get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
	else:
		print("Level 3 is locked!")
