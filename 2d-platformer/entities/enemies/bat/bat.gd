extends CharacterBody2D

@export var speed: int = 100
@export var patrol: Vector2

@export var max_health: int = 2  # Number of hits required to defeat the enemy
var current_health: int
var redval: float

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var kill_zone: Area2D = $KillZone

@onready var sfx_hurt = $sfx_hurt

var is_dead: bool = false
var starting_position: Vector2

func _ready() -> void:
	#initialize movement rules and initial data on-spawn.
	starting_position = position
	velocity = Vector2(-speed, 0)
	current_health = max_health
	redval = 0
	animated_sprite.play("flying")
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func _process(delta: float) -> void:
	if is_dead:
		return

	# Bats patrol in a counterclockwise square patters.
	# To create a bat that moves only horizontally or
	# vertically set the y or x patrol value to 0,
	# respectively.
	if velocity.x != 0:
		if position.x > starting_position.x:
			position.x = starting_position.x
			velocity.x = 0
			velocity.y = -speed
			animated_sprite.flip_h = false
		elif position.x <= starting_position.x - patrol.x:
			position.x = starting_position.x - patrol.x
			velocity.x = 0
			velocity.y = speed
	elif velocity.y != 0:
		if position.y > starting_position.y + patrol.y:
			position.y = starting_position.y + patrol.y
			velocity.x = speed
			velocity.y = 0
			animated_sprite.flip_h = true
		elif position.y <= starting_position.y:
			position.y = starting_position.y
			velocity.x = -speed
			velocity.y = 0

	move_and_slide()

	#deal damage
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider().is_in_group("player"):
			collider.get_collider().take_damage(1)
			
	#show damage amount
	flash_red_show_hp()
	
func flash_red_show_hp() -> void:
	#this is a function to make the enemy flash with a frequency
	#proportional to their ratio of max HP to their missing HP
	#if they are missing any HP. This is to make enemies communicvate this information
	#to the player.
	var missing_hp = max_health - current_health
	var missable_hp = max_health - 1
	
	var cur_timer = GameManager.enemy_timer_current
	
	if missing_hp == 0 or current_health == 0:
		redval = 0.0
	
	elif (cur_timer % int((100 * ((1.0 * current_health) / (1.0 * max_health)))) <= 15) and (redval <= 0.001):
		#see if the enemy should be currently flashing
		redval = 0.1
	
	elif (cur_timer % int((100 * ((1.0 * current_health) / (1.0 * max_health)))) <= 15):
		redval *= 1.5
	
	else:
		redval = 0.0
		
	var temp_num = 1 - redval
	
	if temp_num >= 1:
		temp_num = 1
	elif temp_num <= 0:
		temp_num = 0
		
	modulate = Color(1, temp_num, temp_num, 1)

func _on_kill_zone_body_entered(body: Node):
	#extra condition is to make bat less damagey when player stomps it
	if body.is_in_group("player") and not is_dead:
		sfx_hurt.play()
		take_damage(body)
		body.bounce()

func take_damage(player: Node) -> void:
	# If the player has double_damage enabled, the enemy will take instant damage
	if player.double_damage:
		print("Double damage!")
		current_health -= 2
		print("Enemy hit! Health left:", current_health)
	else:
		current_health -= 1  # Normal damage
		print("Enemy hit! Health left:", current_health)

	if current_health <= 0:
		kill_bat()
	else:
		animated_sprite.play("hurt")  # Play hurt animation if available

func kill_bat() -> void:
	print("Bat killed!")
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	
	#message
	GameManager.display_text = "DEFEATED BAT!"
	GameManager.display_text_timer = 100
	
	await get_tree().create_timer(0.5).timeout
	#OK!
	#We cannot have the bat be removed, as it must be able to be resummoned later
	#so teleport it to the dead realm, far away
	#it will come back if revived.
	position = GameManager.dead_position

func heal_and_respawn() -> void:
	#does what it says. caLLed by gamemanager on player death.
	animated_sprite.play("flying")
	current_health = max_health
	position = starting_position
	is_dead = false
	collision_shape.set_deferred("disabled", false)
