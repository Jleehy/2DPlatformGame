extends Control

func _on_play_pressed() -> void:
	# Transition to the gameplay scene
	get_tree().change_scene_to_file("res://scenes/main/level_1.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/options.tscn")
