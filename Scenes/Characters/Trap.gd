extends Ennemy

class_name Trap

# Called when the node enters the scene tree for the first time.
func _ready():
	type = "Trap"
	sprite_texture = preload("res://Assets/Images/Characters/Ennemies/trap_placeholder.png")
	sprite.texture = sprite_texture
