class_name Snake

extends Node2D

const BODY_SEGMENT_SIZE = 32

signal on_point_scored(points: int)
signal on_game_over

enum CollisionDirection {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

var body_parts = []
var body_texture = preload("res://Assets/Images/snake_placeholder.png")
@onready var snake_parts: Node = $SnakeParts
@onready var timer:Timer = $Timer

@export var walls: Walls

var walls_dict
var move_direction = Vector2.ZERO

var food_spawner
var points = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var head = Sprite2D.new()
	head.position = Vector2(0,0)
	head.scale = Vector2(1,1)
	head.texture = body_texture
	snake_parts.add_child(head)
	body_parts.append(head)
	# setup timer
	timer.timeout
	
	walls_dict = walls.walls_dict
	food_spawner = get_tree().get_first_node_in_group('Food_spawner') as FoodSpawner

func _input(event):
	if((event.is_action_pressed("ui_right") || event.is_action_pressed("right")) && move_direction.x != -1):
		move_direction = Vector2.RIGHT
	elif((event.is_action_pressed("ui_left") || event.is_action_pressed("left")) && move_direction.x != 1):
		move_direction = Vector2.LEFT
	elif((event.is_action_pressed("ui_up") || event.is_action_pressed("up")) && move_direction.y != 1):
		move_direction = Vector2.UP
	elif((event.is_action_pressed("ui_down") || event.is_action_pressed("down")) && move_direction.y != -1):
		move_direction = Vector2.DOWN

func move_to_position(new_position):
	if (body_parts.size() > 1) : 
		var last_element = body_parts.pop_back()
		last_element.position = body_parts[0].position
		body_parts.insert(1, last_element)
	position = new_position
	body_parts[0].position = new_position

func _on_timer_timeout():
	var new_head_position = position + move_direction * BODY_SEGMENT_SIZE
	var wall_collision = check_wall_collision(new_head_position)
	if wall_collision == null:
		move_to_position(new_head_position)
	else:
		var position_after_wall_collision = get_position_after_wall_collision(wall_collision, new_head_position)
		new_head_position = position_after_wall_collision
		move_to_position(position_after_wall_collision)
	if(new_head_position == food_spawner.food_position):
		points += 1
		on_point_scored.emit(points)
		food_spawner.destroy_food()
		food_spawner.spawn_food()
		add_body_part()
		timer.wait_time *= 0.95
	var snake_collision = check_snake_collision(new_head_position)
	
	if snake_collision :
		timer.stop()
		on_game_over.emit()
func check_wall_collision(new_head_position: Vector2):
	if (new_head_position.x == walls_dict['left'].position.x && move_direction == Vector2.LEFT):
		return CollisionDirection.LEFT
	elif (new_head_position.x == walls_dict['right'].position.x && move_direction == Vector2.RIGHT):
		return CollisionDirection.RIGHT
	elif (new_head_position.y == walls_dict['top'].position.y && move_direction == Vector2.UP):
		return CollisionDirection.TOP
	elif (new_head_position.y == walls_dict['bottom'].position.y && move_direction == Vector2.DOWN):
		return CollisionDirection.BOTTOM
func get_position_after_wall_collision(wall_collision :CollisionDirection, new_head_position : Vector2):
	if ((wall_collision == CollisionDirection.LEFT || wall_collision == CollisionDirection.RIGHT)&& new_head_position.y <= 0) :
		move_direction = Vector2.DOWN
	elif ((wall_collision == CollisionDirection.LEFT || wall_collision == CollisionDirection.RIGHT)&& new_head_position.y > 0) :
		move_direction = Vector2.UP
	elif ((wall_collision == CollisionDirection.TOP || wall_collision == CollisionDirection.BOTTOM)&& new_head_position.x <= 0) :
		move_direction = Vector2.RIGHT
	elif ((wall_collision == CollisionDirection.TOP || wall_collision == CollisionDirection.BOTTOM)&& new_head_position.x > 0) :
		move_direction = Vector2.LEFT
	
	return body_parts[0].position + move_direction * BODY_SEGMENT_SIZE
func add_body_part():
	var new_part = Sprite2D.new()
	new_part.texture = body_texture
	new_part.scale = Vector2(.9,.9)
	snake_parts.add_child(new_part)
	new_part.position = body_parts[-1].position - move_direction * BODY_SEGMENT_SIZE
	body_parts.append(new_part)
func check_snake_collision(new_head_position) :
	var body_parts_without_head = body_parts.slice(1, body_parts.size())
	if (body_parts_without_head.filter(func (part): return part.position == new_head_position)):
		return true
	return false
