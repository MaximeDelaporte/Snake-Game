class_name HeroSpawner

extends Node2D

@export var walls : Walls
@export var traps : Traps
@export var heroes_party : HeroesParty
var warrior_scene = preload("res://Scenes/Characters/Warrior.tscn")
var archer_scene = preload("res://Scenes/Characters/Archer.tscn")
var spearman_scene = preload("res://Scenes/Characters/Spearman.tscn")

enum HeroesCollection {
	Warrior,
	Archer,
	Spearman,
}

const BODY_SEGMENT_SIZE = 32

var hero: Hero

# Called when the node enters the scene tree for the first time.
func spawn_hero():
	var size = HeroesCollection.size()	
	if (hero != null) :
		hero.queue_free()
	if (heroes_party.heroes_party.size() >= size):
		return null
	var chosen_hero = HeroesCollection.keys()[round(randi_range(0, size -1))]
	var random_key = HeroesCollection[chosen_hero]
	for hero_in_party in heroes_party.heroes_party:
		if (hero_in_party.type == chosen_hero):
			return spawn_hero()
	if (random_key == HeroesCollection.Warrior):
		hero = warrior_scene.instantiate()
	elif (random_key == HeroesCollection.Archer):
		hero = archer_scene.instantiate()
	elif(random_key == HeroesCollection.Spearman) :
		hero = spearman_scene.instantiate()
	else : 
		return null
	add_child(hero)
	var hero_position = generate_position()
	while traps.is_on_trap_position(hero_position):
		hero_position = generate_position()
	hero.position = hero_position

func destroy_hero():
	if (hero != null) :
		hero.queue_free()
		await get_tree().create_timer(10.0).timeout
		spawn_hero()
func generate_position():
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y+ BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	# add_child(food)
	return Vector2(x_pos, y_pos)
