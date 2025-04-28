extends Area2D

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	#when the player enters this area do things to load the next level
	if body.name == "Player":
		GameManager.initialize_level("level_" + str(GameManager.current_level_number + 1))
		GameManager.player_progress = Vector2.ZERO
		GameManager.current_level_number += 1
		GameManager.respawn_player(body)
		GameManager.current_checkpoint_number = 0
		GameManager.checkpoints_list = []
	
func _ready() -> void:
	#set up initial data for this
	var transition = $CanvasLayer2/Transition 
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
	
