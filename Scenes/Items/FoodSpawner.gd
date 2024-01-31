class_name FoodSpawner

extends Node2D

@export var walls : Walls
@export var food_scene: PackedScene

const BODY_SEGMENT_SIZE = 32

var food_position: Vector2
var food: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_food()
func spawn_food():
	food = food_scene.instantiate()
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y+ BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	add_child(food)
	food_position = Vector2(x_pos, y_pos)
	food.position = food_position
func destroy_food():
	if (food != null) :
		food.queue_free()
