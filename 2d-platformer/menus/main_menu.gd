extends Control

#add the correct menu as needed
func _on_play_pressed() -> void:
	# Transition to the gameplay scene
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

#add the correct menu as needed
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/options.tscn")

#add the correct menu as needed
func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/level_select.tscn")
