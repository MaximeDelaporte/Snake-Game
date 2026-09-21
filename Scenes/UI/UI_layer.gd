class_name UILayer

extends CanvasLayer

const MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"

@onready var restart_button = $BoxContainer/Restart 
@onready var quit_button = $BoxContainer/Quit
@onready var buttonContainer: HBoxContainer = $BoxContainer

@onready var game_over_label = $GameOverLabel
@onready var points_label = $PointsLabel


@onready var heroes: HeroesParty = $"../HeroesParty"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heroes.on_game_over.connect(on_game_over)
	heroes.on_point_scored.connect(on_points_scored)

func on_game_over() -> void:
	buttonContainer.show()
	game_over_label.show()
	get_tree().paused = true
	restart_button.grab_focus()

func on_points_scored(points: int) -> void:
	points_label.text = "Points : %d" % points

func _on_restart_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	if error != OK:
		get_tree().paused = true
		push_error('Could not restart; %s' % error_string(error))

func _on_quit_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MENU_SCENE)
	if error != OK:
		get_tree().paused = true
		push_error("Could not open menu: %s" % error_string(error))
