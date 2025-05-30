extends Area2D

var is_player_inside: bool = false
var my_text: String = "STRING FETCH FAILURE."

func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Get message from GameManager
	if (GameManager.sign_messages_list.size() > GameManager.current_level_number and
		GameManager.sign_messages_list[GameManager.current_level_number].size() > GameManager.sign_manager_counter):
		
		my_text = GameManager.sign_messages_list[GameManager.current_level_number][GameManager.sign_manager_counter]
		GameManager.sign_manager_counter += 1

func _on_body_entered(body: Node) -> void:
	#display message when player touches this
	if body.name == "Player":
		GameManager.display_text = my_text
		is_player_inside = true

func _on_body_exited(body: Node) -> void:
	#track player location
	if body.name == "Player":
		is_player_inside = false

func _process(delta: float) -> void:
	#as player is within this, set the text timer so text doesn't go away until the player leaves.
	if is_player_inside:
		GameManager.display_text_timer = 100
