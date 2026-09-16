class_name FloorSpike

extends Node3D
@onready var sprite: Sprite3D = $Sprite3D

func _ready():
	sprite.texture = preload("res://Assets/Images/Characters/Ennemies/trap_placeholder.png")
