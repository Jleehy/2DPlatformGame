extends Control
@onready var player: Node = $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_level_2_pressed() -> void:
	if GameManager.level2_unlocked:
		get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
	else:
		print("Level 2 is locked!")
