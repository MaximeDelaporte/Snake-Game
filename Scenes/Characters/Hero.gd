class_name Hero

extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var is_hurt:bool = false
var type
var sprite_texture
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(delta):
	pass
func attack():
	pass
func on_hit():
	is_hurt = true
	while is_hurt : 
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
func on_invulnerability_stop() :
	is_hurt = false
	sprite.modulate = Color.WHITE
