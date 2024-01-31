extends Node2D

class_name Ennemy

@onready var sprite: Sprite2D = $Sprite2D
var type:String
var sprite_texture
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attacks():
	pass
func dies():
	pass
func on_contact():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
