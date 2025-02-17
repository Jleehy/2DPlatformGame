extends CharacterBody2D

#Player physics variables
@export var speed: int = 300
@export var jump_speed: int = -1200
@export var gravity: int = 4000

#player physics variables 2: Advanced ones added by Henry
@export var minimum_speed_percentage: float = 0.30;
@export var player_input_acceleration_percent: float = 0.25;
@export var friction_value: float = 0.84; #this is the %momentum conserved
@export var air_control_loss: float = 0.30;
@export var facing_direction: String = "left";
@export var terminal_velocity: int = 40000;

#Other player variables
@export var deathtimer: int = -1;

var level_bounds: Rect2
var last_spawn: Vector2

func _ready() -> void:
	$AnimatedSprite2D.play()
	#set up the player start position
	#TODO: Modify based on the level
	position = Vector2(400, 400)
	
	level_bounds = get_node("/root/Main/Level/TileMapLayer").get_used_rect() # Get level bounds

	var cellsize = 16;
	level_bounds.position.x *= cellsize;
	level_bounds.position.y *= cellsize;
	level_bounds.size.x *= cellsize;
	level_bounds.size.y *= cellsize;
	
	#setup initial spawn point
	set_save()

func _physics_process(delta: float) -> void:
	# Different Physics apply to the character if they are on the ground or in the air.
	if is_on_floor():
		# The player comes to a halt rather quickly, but not immidiatetly
		if abs(velocity.x) < speed * minimum_speed_percentage:
			#only apply this if the player is not trying to move.
			if (not InputManager.is_move_left_pressed()) and (not InputManager.is_move_right_pressed()):
				velocity.x = 0
		else:
			velocity.x = velocity.x * friction_value
		
		# Accelerate the player if they try and move.
		if InputManager.is_move_left_pressed():
			velocity.x += -1 * speed * player_input_acceleration_percent
			facing_direction = "left"
		if InputManager.is_move_right_pressed():
			velocity.x += speed * player_input_acceleration_percent
			facing_direction = "right"
	else:
		# The player comes to a halt rather quickly, but not immidiatetly
		if abs(velocity.x) < speed * (minimum_speed_percentage * air_control_loss):
			#only apply this if the player is not trying to move.
			if (not InputManager.is_move_left_pressed()) and (not InputManager.is_move_right_pressed()):
				velocity.x = 0
		else:
			velocity.x = velocity.x * (1 - ((1 - friction_value) * air_control_loss))
		
		# Accelerate the player if they try and move.
		if InputManager.is_move_left_pressed():
			velocity.x += -1 * speed * air_control_loss * player_input_acceleration_percent
			facing_direction = "left"
		if InputManager.is_move_right_pressed():
			velocity.x += speed * air_control_loss * player_input_acceleration_percent
			facing_direction = "right"

	#Check for terminal velocity
	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity

	# Update the player animation based on current velocity.
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.flip_h = facing_direction == "left"
		if is_on_floor():
			$AnimatedSprite2D.animation = "run"
		else:
			if velocity.y < 0:
				$AnimatedSprite2D.animation = "jump"
			else:
				$AnimatedSprite2D.animation = "fall"
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.animation = "idle"

	# Apply gravity.
	velocity.y += gravity * delta

	#lastly, handle bounds of the screen
	if position.x < level_bounds.position.x + 16:
		position.x = level_bounds.position.x + 16
		#stop moving that way
		if velocity.x < 0:
			velocity.x = 0
	
	elif position.x > level_bounds.position.x + level_bounds.size.x - 16:
		position.x = level_bounds.position.x + level_bounds.size.x - 16
		if velocity.x > 0:
			velocity.x = 0
			
	#the top and the bottom of the screen both kill you
	if (position.y < level_bounds.position.y) or (position.y > level_bounds.position.y + level_bounds.size.y):
		#die
		die()
		

	# Move the player.
	if not isDead():
		move_and_slide()
	
	else:
		#handle a few things to make the dead player look a bit better
		$AnimatedSprite2D.animation = "idle"
		
		if $AnimatedSprite2D.rotation_degrees < 90:
			$AnimatedSprite2D.rotation_degrees += 5
		else:
			$AnimatedSprite2D.rotation_degrees = 90
			
		deathtimer -= 1;
		
		if deathtimer == 0:
			#done being "dead", do back to being alive now
			$AnimatedSprite2D.rotation_degrees = 0
			
			#respawn the enemies and such.
			resetEnemies()
			
			#go back to player spawn
			goToSpawn()
			
			deathtimer = -1
			

	# Add jump force if the jump button is pressed and the player is on the floor.
	if InputManager.is_jump_pressed() and is_on_floor() and not isDead():
		velocity.y = jump_speed
		#AudioManager.play_sound(jump_sound_here)  # Play jump sound

func isDead() -> bool:
	return deathtimer != -1

func resetEnemies() -> void:
	#TODO
	pass
	
func goToSpawn() -> void:
	#send the player back to their spawn point
	#teleport back to latest spawn point, stop momentum
	velocity.x = 0
	velocity.y = 0
	
	position.x = last_spawn.x
	position.y = last_spawn.y

func set_save() -> void:
	last_spawn.x = position.x
	last_spawn.y = position.y

func die() -> void:
	#do not die while already dead lol
	if isDead():
		return
	
	print("Died!")
	
	deathtimer = 50
