class_name Warrior

extends Hero

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = preload("res://Assets/Images/Characters/Heroes/warrior_placeholder.png")
	type = "Warrior"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
