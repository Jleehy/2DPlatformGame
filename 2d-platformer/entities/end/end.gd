extends Area2D

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		#fade out first
		var transition = get_node("/root/level_" + str(GameManager.current_level_number) + "/CanvasLayer2/Transition")
		if transition:
			print("LEVEL ID: level_" + str(GameManager.current_level_number))
			transition.fade_in("FINISH!")
		
			await get_tree().create_timer(3).timeout
		
		#reset player data in prep for next level.
		GameManager.player_progress = Vector2.ZERO
		GameManager.respawn_player(body)
		
		#load the next level.
		get_tree().change_scene_to_file("res://scenes/levels/level_" + str(GameManager.current_level_number + 1) + ".tscn")

		#unlock the grapple
		#as is needed
		if GameManager.current_level_number >= 2:
			body.can_grapple = true
		
		else:
			body.can_grapple = false

func _ready() -> void:
	#prep collision rules.
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
