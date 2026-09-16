class_name HeroesParty
extends Node3D

const HERO_SPRITE_SIZE = 1
const BILLBOARD_HEIGHT = 0.5
const DEFAULT_MOVE_DIRECTION = Vector2.DOWN
const DEFAULT_FORWARD = Vector3(0, 0, 1)

signal on_point_scored(points: int)
signal on_game_over
var this_script = get_script()
var heroes_party : Array[Hero] = []

enum CollisionDirection {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}
@onready var heroes: Node = $Heroes
@onready var invulnerability_timer:Timer = $Invulnerability
@onready var is_invulnerable = false
@onready var party_clock: IncrementalTimer = $PartyClock

@export var walls: Walls
@export var hazard_spawner: HazardSpawner
@export var hero_scene: PackedScene
@export var starting_hero_definitions: Array[HeroDefinition]
@export var enemy_spawner: EnemySpawner
@export var item_spawner: ItemSpawner
@export var base_move_interval := 0.2


var walls_dict
var move_direction = DEFAULT_MOVE_DIRECTION
var grid_position = Vector2.ZERO

var heroes_spawner
var points = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	for starting_hero_definition in starting_hero_definitions:
		if starting_hero_definition == null:
			continue
		var new_hero := create_hero(starting_hero_definition)
		if new_hero != null :
			heroes_party.append(new_hero)
	var head = get_leader()
	grid_position = Vector2.ZERO
	sync_party_origin()
	set_actor_grid_position(head, Vector2.ZERO)
	walls_dict = walls.walls_dict
	heroes_spawner = get_tree().get_first_node_in_group('Hero_spawner') as HeroSpawner
	heroes_spawner.call_deferred("spawn_hero")
	call_deferred("movement_loop")
func create_hero(definition: HeroDefinition) -> Hero:
	var hero := hero_scene.instantiate() as Hero
	heroes.add_child(hero)
	hero.apply_definition(definition)
	hero.configure_attack(party_clock)
	return hero
func _unhandled_input(event):
	if event.is_action_pressed("ui_right") || event.is_action_pressed("right"):
		try_set_move_direction(get_camera_relative_direction(Vector3.RIGHT))
	elif event.is_action_pressed("ui_left") || event.is_action_pressed("left"):
		try_set_move_direction(get_camera_relative_direction(Vector3.LEFT))
	elif event.is_action_pressed("ui_up") || event.is_action_pressed("up"):
		try_set_move_direction(get_camera_relative_direction(Vector3.FORWARD))
	elif event.is_action_pressed("ui_down") || event.is_action_pressed("down"):
		try_set_move_direction(get_camera_relative_direction(Vector3.BACK))
func get_leader() -> Hero:
	cleanup_party()
	if heroes_party.is_empty():
		return null
	return heroes_party[0] as Hero
func get_leader_grid_position() -> Vector2:
	var leader := get_leader()
	if leader == null:
		return grid_position
	return get_actor_grid_position(leader)
func get_leader_direction() -> Vector2:
	return move_direction
func is_leader(hero: Hero) -> bool:
	return hero != null and hero == get_leader()
func move_to_position(new_position):
	cleanup_party()
	grid_position = new_position
	sync_party_origin()
	if heroes_party.is_empty():
		on_game_over.emit()
		return

	var previous_positions: Array[Vector2] = []
	for hero in heroes_party:
		previous_positions.append(get_actor_grid_position(hero))

	var surviving_heroes: Array[Hero] = []
	var removed_heroes: Array[Hero] = []
	for index in range(heroes_party.size()):
		var hero = heroes_party[index]
		var target_position = new_position if index == 0 else previous_positions[index - 1]
		if hazard_spawner.get_hazard_at_position(target_position) and not is_invulnerable:
			removed_heroes.append(hero)
			continue
		set_actor_grid_position(hero, target_position)
		surviving_heroes.append(hero)

	heroes_party = surviving_heroes
	for hero in removed_heroes:
		hero.queue_free()

	if heroes_party.is_empty():
		on_game_over.emit()
	elif not removed_heroes.is_empty():
		trigger_party_invulnerability()
func movement_loop() -> void:
	while is_inside_tree():
		await party_clock.wait_seconds(base_move_interval)
		if not is_inside_tree():
			return
		take_movement_turn()
func take_movement_turn() -> void:
	cleanup_party()
	if heroes_party.is_empty():
		on_game_over.emit()
	else :
		var new_head_position = grid_position + move_direction * HERO_SPRITE_SIZE
		var wall_collision = check_wall_collision(new_head_position)
		if wall_collision == null:
			pass
		else:
			var position_after_wall_collision = get_position_after_wall_collision(wall_collision, new_head_position)
			new_head_position = position_after_wall_collision
		take_hero_attack_turns()
		if is_party_collision(new_head_position):
			on_game_over.emit()
			return
		if hazard_spawner.get_hazard_at_position(new_head_position):
			get_hit(get_leader())
			return
		var enemy := enemy_spawner.get_enemy_at_position(new_head_position)
		if enemy != null:
			var leader := get_leader()
			var enemy_was_defeated := leader.attack.attack_actor(
				enemy,
				new_head_position,
				get_leader_grid_position(),
				move_direction,
				1,
				move_direction
			)
			if not enemy_was_defeated:
				return
		move_to_position(new_head_position)
		item_spawner.collect_item_at_position(new_head_position, self)
		if(heroes_spawner.hero != null && new_head_position == heroes_spawner.get_hero_grid_position()):
			add_points(1)
			add_hero_to_party(heroes_spawner.hero)
			heroes_spawner.destroy_hero()

func take_hero_attack_turns() -> void:
	if enemy_spawner == null:
		return
	for hero in heroes_party:
		if not is_instance_valid(hero) or not hero.attack.is_ready():
			continue
		var origin := get_actor_grid_position(hero)
		for target_position in hero.attack.get_affected_positions(
			origin,
			move_direction
		):
			var enemy := enemy_spawner.get_enemy_at_position(target_position)
			if enemy == null:
				continue
			hero.attack.attack_actor(
				enemy,
				target_position,
				origin,
				move_direction,
				1,
				target_position - origin
			)
			break

func is_party_collision(new_head_position: Vector2) -> bool:
	for hero in heroes_party.slice(1):
		if is_instance_valid(hero) and get_actor_grid_position(hero) == new_head_position:
			return true
	return false

func has_hero_on_grid_position(target_position: Vector2) -> bool:
	for hero in heroes_party:
		if is_instance_valid(hero) and get_actor_grid_position(hero) == target_position:
			return true
	return false

func check_wall_collision(new_head_position: Vector2):
	if (new_head_position.x == walls_dict['left'].position.x && move_direction == Vector2.LEFT):
		return CollisionDirection.LEFT
	elif (new_head_position.x == walls_dict['right'].position.x && move_direction == Vector2.RIGHT):
		return CollisionDirection.RIGHT
	elif (new_head_position.y == walls_dict['top'].position.z && move_direction == Vector2.UP):
		return CollisionDirection.TOP
	elif (new_head_position.y == walls_dict['bottom'].position.z && move_direction == Vector2.DOWN):
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
	
	return grid_position + move_direction * HERO_SPRITE_SIZE

func add_hero_to_party(hero: Hero)->void:
	if hero == null or hero.definition == null:
		push_error("Collected hero has no HeroDefinition")
		return
	var new_hero := create_hero(hero.definition)
	var tail := heroes_party[-1]
	var follower_position := (
		get_actor_grid_position(tail) - move_direction * HERO_SPRITE_SIZE
	) as Vector2
	set_actor_grid_position(new_hero, follower_position)
	heroes_party.append(new_hero)
	multiply_party_speed(1.0/0.95)
func has_hero_definition(target: HeroDefinition) -> bool:
	for member in heroes_party:
		if (
			is_instance_valid(member)
			and member.definition == target
		):
			return true
	return false
func get_hit(hero: Hero) -> bool:
	if is_invulnerable or not is_leader(hero):
		return false
	
	var was_depleted := hero.health.take_damage(1)
	
	if not was_depleted:
		return false
	heroes_party.erase(hero)
	hero.queue_free()
	cleanup_party()
	if heroes_party.is_empty():
		on_game_over.emit()
		return true
	
	promote_next_leader()
	trigger_party_invulnerability()
	
	return true
		
func promote_next_leader() -> void:
	var new_leader := get_leader()
	if new_leader == null:
		return
	grid_position = get_actor_grid_position(new_leader)
	sync_party_origin()
	refresh_actor_local_positions()

func refresh_actor_local_positions() -> void:
	for hero in heroes_party:
		var hero_grid_position := get_actor_grid_position(hero)
		hero.position = Vector3(
			hero_grid_position.x - grid_position.x,
			BILLBOARD_HEIGHT,
			hero_grid_position.y - grid_position.y
		)

func _on_invulnerability_timeout():
	is_invulnerable = false
	cleanup_party()
	if !heroes_party.is_empty():
		for hero in heroes_party:
			hero.on_invulnerability_stop()

func _on_game_over():
	get_tree().paused = true;

func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	on_point_scored.emit(points)

func grid_to_world(grid: Vector2) -> Vector3:
	return Vector3(grid.x, 0, grid.y)

func get_actor_grid_position(actor: Node3D) -> Vector2:
	if actor.has_meta("grid_position"):
		return actor.get_meta("grid_position") as Vector2
	return grid_position

func set_actor_grid_position(actor: Node3D, grid: Vector2) -> void:
	actor.set_meta("grid_position", grid)
	actor.position = Vector3(grid.x - grid_position.x, BILLBOARD_HEIGHT, grid.y - grid_position.y)

func cleanup_party() -> void:
	for index in range(heroes_party.size() -1, -1, -1):
		if not is_instance_valid(heroes_party[index]):
			heroes_party.remove_at(index)

func trigger_party_invulnerability() -> void:
	for left_hero in heroes_party:
		left_hero.on_hit()
	$Invulnerability.start()
	is_invulnerable = true

func sync_party_origin() -> void:
	position = grid_to_world(grid_position)

func get_forward_world_direction() -> Vector3:
	return Vector3(move_direction.x, 0, move_direction.y).normalized()

func get_camera_focus_position() -> Vector3:
	if !heroes_party.is_empty() and is_instance_valid(heroes_party[0]):
		return heroes_party[0].global_position
	return global_position + Vector3.UP * BILLBOARD_HEIGHT

func get_camera_base_focus_position() -> Vector3:
	return global_position + Vector3.UP * BILLBOARD_HEIGHT

func try_set_move_direction(new_direction: Vector2) -> void:
	if new_direction == -move_direction:
		return
	move_direction = new_direction

func get_camera_relative_direction(local_direction: Vector3) -> Vector2:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return move_direction

	var world_direction = camera.global_basis * local_direction
	world_direction.y = 0
	if world_direction.length_squared() == 0:
		return move_direction

	return snap_world_direction_to_grid(world_direction.normalized())

func snap_world_direction_to_grid(world_direction: Vector3) -> Vector2:
	if absf(world_direction.x) > absf(world_direction.z):
		return Vector2(signf(world_direction.x), 0)
	return Vector2(0, signf(world_direction.z))
func set_party_speed_multiplier(value: float) -> void:
	party_clock.speed_multiplier = value
func multiply_party_speed(factor: float) -> void:
	set_party_speed_multiplier(
		party_clock.speed_multiplier * maxf(0.0, factor)
	)
