extends Node2D
var cycle_full_time = 800
var start_position
var cycle_progress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set up data about this entity
	cycle_progress = 0
	start_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#move the platform based upon the time within the cycle
	var x_mod = 0
	var y_mod = (800 / cycle_full_time) * abs((cycle_full_time / 2) - cycle_progress)
	
	global_position.x = start_position.x + x_mod
	global_position.y = start_position.y - y_mod
	
	cycle_progress += 1
	#reste cycle when over
	if cycle_progress == cycle_full_time:
		cycle_progress = 0

func reset_position() -> void:
	#resets the player's position upon the player's death.
	position = start_position
	cycle_progress = 0
	
