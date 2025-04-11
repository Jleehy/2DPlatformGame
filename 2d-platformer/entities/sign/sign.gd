extends Area2D

var is_player_inside: bool = false
var my_text: String = "No text found."
		
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		is_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		is_player_inside = false
		
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	#pull the message for this specific sign out of the list.
	if len(GameManager.sign_messages_list) > GameManager.current_level_number:
		if len(GameManager.sign_messages_list[GameManager.current_level_number]) > GameManager.sign_manager_counter:
			my_text = GameManager.sign_messages_list[GameManager.current_level_number][GameManager.sign_manager_counter]
			GameManager.sign_manager_counter += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_player_inside:
		GameManager.display_text_timer = 100
		GameManager.display_text = my_text
