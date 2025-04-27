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
			
		GameManager.player_progress = Vector2.ZERO
		GameManager.respawn_player(body)
		get_tree().change_scene_to_file("res://scenes/levels/level_" + str(GameManager.current_level_number + 1) + ".tscn")

		#unlock the grapple
		#I have to do it this way if level 3 doesn't exist yet
		if GameManager.current_level_number >= 2:
			body.can_grapple = true
		
		else:
			body.can_grapple = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
