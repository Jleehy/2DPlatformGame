class_name Plant
extends CharacterBody2D

var bullet_scene: Resource = preload("res://entities/enemies/plant/plant_bullet.tscn")
@export var bullet_speed: int = 50

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

@export var max_health: int = 2  # Number of hits required to defeat the enemy
var current_health: int
var redval: float

var is_dead: bool = false
var direction: int = -1
var should_shoot: bool = false

@export var starting_position: Vector2

func _ready() -> void:
	animated_sprite.play("idle")
	current_health = max_health
	starting_position = position
	redval = 0
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(delta: float) -> void:
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

func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_dead:
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
		kill_plant()
	else:
		animated_sprite.play("hurt")  # Play hurt animation if available


func _on_animated_sprite_2d_animation_looped() -> void:
	# Fire on animation loops to keep the plants and
	# bullets visually in sync.
	if animated_sprite.animation == "attack":
		shoot_bullet()

func set_direction(new_direction: int) -> void:
	if new_direction < 0:
		direction = -1
		animated_sprite.flip_h = false
	else:
		direction = 1
		animated_sprite.flip_h = true

func set_shoot(shoot: bool) -> void:
	if should_shoot != shoot:
		should_shoot = shoot
		if should_shoot and not is_dead:
			animated_sprite.play("attack")
		else:
			animated_sprite.play("idle")

func shoot_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.set_direction(Vector2(direction, 0))
	add_child(bullet)

func kill_plant() -> void:
	print("Plant killed!")
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	
	#message
	GameManager.display_text = "DEFEATED PLANT!"
	GameManager.display_text_timer = 100
	
	await get_tree().create_timer(0.5).timeout
	#OK!
	#We cannot have the thing be removed, as it must be able to be resummoned later
	#so teleport it to the dead realm, far away
	#it will come back if revived.
	position = GameManager.dead_position
	
func heal_and_respawn() -> void:
	#does what it says. caLLed by gamemanager on player death.
	current_health = max_health
	position = starting_position
	is_dead = false
	collision_shape.set_deferred("disabled", false)
