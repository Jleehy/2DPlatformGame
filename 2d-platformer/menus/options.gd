extends Control

@onready var sound_button = $Buttons/Sound  # Reference to Sound Button
@onready var icon = $Buttons/Sound/TextureRect  # Reference to TextureRect
var muted: bool = false
var sound_on_icon = preload("res://art/menu/buttons/Volume.png")
var sound_off_icon = preload("res://art/menu/buttons/VolumeMuted.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_sound_pressed() -> void:
	if muted:
		icon.texture = sound_on_icon
		muted = false
	else:
		icon.texture = sound_off_icon
		muted = true


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/help.tscn")
