extends Node

func is_jump_pressed() -> bool:
	return Input.is_action_pressed("jump")

func is_move_left_pressed() -> bool:
	return Input.is_action_pressed("move_left")
	
func is_move_right_pressed() -> bool:
	return Input.is_action_pressed("move_right")
