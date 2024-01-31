class_name UILayer

extends CanvasLayer

@onready var restart_button = $%BoxContainer/Restart 
@onready var quit_button = $%BoxContainer/Quit

@onready var game_over_label = $GameOverLabel
@onready var points_label = $PointsLabel


@onready var heroes: HeroesParty = $"../HeroesParty"
var buttonContainer: HBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	heroes.on_game_over.connect(on_game_over)
	heroes.on_point_scored.connect(on_points_scored)
	buttonContainer = get_node("BoxContainer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_game_over():
	buttonContainer.visible = true
	game_over_label.visible = true

func on_points_scored(points: int):
	points_label.text = "Points : %d" % points

func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
