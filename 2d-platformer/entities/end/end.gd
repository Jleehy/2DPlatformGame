extends Area2D

# Called when another body enters the area
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		GameManager.player_progress = Vector2.ZERO
		GameManager.current_level_number += 1
		GameManager.respawn_player(body)
		get_tree().change_scene_to_file("res://scenes/main/level_" + str(GameManager.current_level_number + 1) + ".tscn")

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
