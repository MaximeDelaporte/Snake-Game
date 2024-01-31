class_name Walls

extends Node

var walls_dict = {}
var top_left_corner : Vector2
var bottom_right_corner : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	var walls = get_tree().get_nodes_in_group('Walls') as Array[Node2D]
	for wall in walls:
		if wall.position.x < 0:
			walls_dict['left'] = wall
		elif wall.position.x > 0:
			walls_dict['right'] = wall
		elif wall.position.y > 0:
			walls_dict['bottom'] = wall
		elif wall.position.y < 0:
			walls_dict['top'] = wall
	top_left_corner = Vector2(walls_dict['left'].position.x, walls_dict['top'].position.y)
	bottom_right_corner = Vector2(walls_dict['right'].position.x, walls_dict['bottom'].position.y)

