class_name HeroSpawner

extends Node3D

@export var walls : Walls
@export var hazard_spawner : HazardSpawner
@export var heroes_party : HeroesParty
@export var hero_scene: PackedScene
@export var hero_definitions: Array[HeroDefinition] = []
const BODY_SEGMENT_SIZE = 1
const BILLBOARD_HEIGHT = 0.5

var hero: Hero

func get_available_definitions() -> Array[HeroDefinition]:
	var available: Array[HeroDefinition] = []
	for definition in hero_definitions:
		if (
			definition != null
			and not heroes_party.has_hero_definition(definition)
		):
			available.append(definition)
	return available
func spawn_hero() -> Hero:
	var available := get_available_definitions()
	if available.is_empty():
		return null
	var chosen_definition := available.pick_random() as HeroDefinition
	var spawned_hero := hero_scene.instantiate() as Hero
	if spawned_hero == null:
		push_error("Hero scene must instantiate as Hero")
		return null
	add_child(spawned_hero)
	spawned_hero.apply_definition(chosen_definition)
	hero = spawned_hero
	var hero_position = generate_position()
	while hazard_spawner.get_hazard_at_position(hero_position) != null or heroes_party.has_hero_on_grid_position(hero_position):
		hero_position = generate_position()
	hero.position = grid_to_world(hero_position)
	return hero

func destroy_hero():
	if (hero != null) :
		hero.queue_free()
		hero = null
		await get_tree().create_timer(10.0).timeout
		spawn_hero()
func generate_position():
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y+ BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE)/ BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	return Vector2(x_pos, y_pos)

func get_hero_grid_position() -> Vector2:
	if hero == null:
		return Vector2.ZERO
	return Vector2(hero.position.x, hero.position.z)

func grid_to_world(grid: Vector2) -> Vector3:
	return Vector3(grid.x, BILLBOARD_HEIGHT, grid.y)
