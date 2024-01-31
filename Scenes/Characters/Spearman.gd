class_name Spearman

extends Hero


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_texture = preload("res://Assets/Images/Characters/Heroes/spearman_placeholder.png")
	sprite.texture = sprite_texture
	type = "Spearman"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
