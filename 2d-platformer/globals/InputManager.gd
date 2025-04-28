extends Node

#Some variables that are used to configure optional controls.
@export var self_death_enabled: bool = true
@export var dev_teleport_enabled: bool = false #use y and u to go back and forward
@export var dev_level_skip_enabled: bool = false #i to use

#helper function to access input
func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

#helper function to access input
func is_move_left_pressed() -> bool:
	return Input.is_action_pressed("move_left")
	
#helper function to access input
func is_move_right_pressed() -> bool:
	return Input.is_action_pressed("move_right")
	
#helper function to access input
func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("dash")

#helper function to access input
func is_crouch_pressed() -> bool:
	return Input.is_action_pressed("crouch")

#helper function to access input
func is_self_death_pressed() -> bool:
	if self_death_enabled:
		return Input.is_action_just_pressed("trigger_self_death")
	
	return false

#helper function to access input
func is_pause_pressed() -> bool:
	return Input.is_action_just_pressed("pause")
	
#helper function to access input
func is_dev_teleport_forwards_pressed() -> bool:
	if dev_teleport_enabled:
		return Input.is_action_just_pressed("dev_next_checkpoint")
		
	return false

#helper function to access input
func is_dev_teleport_backwards_pressed() -> bool:
	if dev_teleport_enabled:
		return Input.is_action_just_pressed("dev_previous_checkpoint")
		
	return false
	
#helper function to access input
func is_grapple_pressed() -> bool:
	return Input.is_action_just_pressed("grapple")

#helper function to access input
func is_dev_next_level_pressed() -> bool:
	if dev_level_skip_enabled:
		return Input.is_action_just_pressed("dev_next_level")
		
	return false
