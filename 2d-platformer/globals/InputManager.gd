extends Node

#Some variables that are used to configure optional controls.
@export var self_death_enabled: bool = true
@export var dev_teleport_enabled: bool = true #use y and u to go back and forward

func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func is_move_left_pressed() -> bool:
	return Input.is_action_pressed("move_left")
	
func is_move_right_pressed() -> bool:
	return Input.is_action_pressed("move_right")
	
func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("dash")
	
func is_crouch_pressed() -> bool:
	return Input.is_action_pressed("crouch")
	
func is_self_death_pressed() -> bool:
	if self_death_enabled:
		return Input.is_action_just_pressed("trigger_self_death")
	
	return false
	
func is_dev_teleport_forwards_pressed() -> bool:
	if dev_teleport_enabled:
		return Input.is_action_just_pressed("dev_next_checkpoint")
		
	return false

func is_dev_teleport_backwards_pressed() -> bool:
	if dev_teleport_enabled:
		return Input.is_action_just_pressed("dev_previous_checkpoint")
		
	return false
