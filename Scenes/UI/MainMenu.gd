extends Control
const GAME_SCENE := "res://Scenes/World/main.tscn"

@onready var play_button: Button = $MarginContainer/CenterContainer/VBoxContainer/PlayButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	play_button.pressed.connect(_on_play_pressed)
	play_button.grab_focus()
func _on_play_pressed() -> void:
	play_button.disabled = true
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK :
		play_button.disabled = false
		play_button.grab_focus()
		push_error("Could not open gameplay: %s" % error_string(error))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
