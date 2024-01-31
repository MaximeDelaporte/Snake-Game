class_name HeroesParty
extends Node2D


const HERO_SPRITE_SIZE = 32

signal on_point_scored(points: int)
signal on_game_over
var this_script = get_script()
var warrior_scene = preload("res://Scenes/Characters/Warrior.tscn")
var archer_scene = preload("res://Scenes/Characters/Archer.tscn")
var spearman_scene = preload("res://Scenes/Characters/Spearman.tscn")
var heroes_party = []
enum CollisionDirection {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}
@onready var heroes: Node = $Heroes
@onready var timer:Timer = $Timer

@export var walls: Walls

var walls_dict
var move_direction = Vector2.ZERO

var heroes_spawner
var points = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var head = warrior_scene.instantiate()
	head.position = Vector2(0,0)
	head.scale = Vector2(1,1)
	heroes.add_child(head)
	heroes_party.append(head)
	# setup timer
	timer.timeout
	
	walls_dict = walls.walls_dict
	heroes_spawner = get_tree().get_first_node_in_group('Hero_spawner') as HeroSpawner
	heroes_spawner.spawn_hero()

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
	position = new_position
	if (heroes_party.size() > 1):
		var old_position = heroes_party[0].position
		var last_element_position = new_position
		var hero
		#heroes_party[0].position = new_position	 
		for i in range(heroes_party.size()):
			hero = heroes_party.pop_at(i)
			old_position = hero.position
			hero.position = last_element_position
			last_element_position = old_position
			heroes_party.insert(i,hero)
	else:

		heroes_party[0].position = new_position
		#heroes_party[0].position = new_position
		
	
func _on_timer_timeout():
	var new_head_position = position + move_direction * HERO_SPRITE_SIZE
	var wall_collision = check_wall_collision(new_head_position)
	if wall_collision == null:
		move_to_position(new_head_position)
	else:
		var position_after_wall_collision = get_position_after_wall_collision(wall_collision, new_head_position)
		new_head_position = position_after_wall_collision
		move_to_position(position_after_wall_collision)
	if(heroes_spawner.hero != null && new_head_position == heroes_spawner.hero.position):
		points += 1
		on_point_scored.emit(points)
		add_hero_to_party(heroes_spawner.hero)
		heroes_spawner.destroy_hero()
		#heroes_spawner.spawn_hero()
	
		timer.wait_time *= 0.95
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
	
	return heroes_party[0].position + move_direction * HERO_SPRITE_SIZE
func add_hero_to_party(hero):
	var new_hero_classname = hero.type.to_lower() + '_scene'
	for propertyInfo in this_script.get_script_property_list():
		if propertyInfo.name == new_hero_classname:
			heroes_spawner.destroy_hero()
			var new_hero_scene = get(propertyInfo.name)
			var new_hero = new_hero_scene.instantiate()
			heroes.add_child(new_hero)
			new_hero.position = heroes_party[0].position - move_direction * HERO_SPRITE_SIZE
			heroes_party.append(new_hero)
