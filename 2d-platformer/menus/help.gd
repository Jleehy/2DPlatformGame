extends Control

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass


#add the correct menu as needed
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_sound_pressed() -> void:
	pass 

#add the correct menu as needed
func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/help.tscn")
