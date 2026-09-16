class_name RatSpawner

extends Node3D

const MAX_RATS := 2
const BODY_SEGMENT_SIZE := 1
const COIN_POINTS := 10
const COIN_DROP_DENOMINATOR := 10

@export var walls: Walls
@export var traps: Traps
@export var heroes_party: HeroesParty
@export var respawn_delay := 2.0
@export var grid_occupancy : GridOccupancy

var rat_scene = preload("res://Scenes/Characters/Enemies/Rat.tscn")
var coin_scene = preload("res://Scenes/Items/Coin.tscn")

@onready var rats: Node3D = $Rats
@onready var coins: Node3D = $Coins

var pending_respawn_count := 0

func _ready() -> void:
	add_to_group("Rat_spawner")
	spawn_until_capacity()

func spawn_until_capacity(excluded_positions: Array = []) -> void:
	while rats.get_child_count() < MAX_RATS:
		spawn_rat(excluded_positions)

func spawn_rat(excluded_positions: Array = []) -> Rat:
	var rat = rat_scene.instantiate() as Rat
	rats.add_child(rat)
	rat.walls = walls
	rat.traps = traps
	rat.heroes_party = heroes_party
	rat.spawner = self
	rat.set_grid_position(generate_position(excluded_positions))
	return rat

func remove_rat_at_position(target_position: Vector2) -> bool:
	var rat = get_rat_at_position(target_position)
	if rat == null:
		return false

	rats.remove_child(rat)
	rat.queue_free()
	if randi_range(1, COIN_DROP_DENOMINATOR) == 1:
		spawn_coin(target_position)
	queue_delayed_respawn([target_position])
	return true

func collect_coin_at_position(target_position: Vector2) -> int:
	var coin = get_coin_at_position(target_position)
	if coin == null:
		return 0

	coins.remove_child(coin)
	coin.queue_free()
	return COIN_POINTS

func spawn_coin(grid_position: Vector2) -> void:
	if get_coin_at_position(grid_position) != null:
		return

	var coin = coin_scene.instantiate() as Coin
	coins.add_child(coin)
	coin.set_grid_position(grid_position)

func queue_delayed_respawn(excluded_positions: Array = []) -> void:
	pending_respawn_count += 1
	respawn_after_delay(excluded_positions)

func respawn_after_delay(excluded_positions: Array = []) -> void:
	await get_tree().create_timer(respawn_delay).timeout
	if not is_inside_tree():
		return
	pending_respawn_count = max(0, pending_respawn_count - 1)
	spawn_until_capacity(excluded_positions)

func generate_position(excluded_positions: Array = []) -> Vector2:
	for _attempt in range(128):
		var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
		var y_pos = round(randi_range(walls.top_left_corner.y + BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
		var grid_position = Vector2(x_pos, y_pos)
		if is_grid_position_free(grid_position, null, excluded_positions):
			return grid_position
	return Vector2.ZERO

func is_grid_position_free(target_position: Vector2, ignored_rat: Rat = null, excluded_positions: Array = []) -> bool:
	return grid_occupancy.is_grid_position_free(
		target_position,
		ignored_rat,
		excluded_positions
	)
	if not is_inside_wall_bounds(target_position):
		return false
	if traps.is_on_trap_position(target_position):
		return false
	if target_position == heroes_party.grid_position:
		return false
	if heroes_party.has_hero_on_grid_position(target_position):
		return false
	if is_position_excluded(target_position, excluded_positions):
		return false
	if get_rat_at_position(target_position, ignored_rat) != null:
		return false
	if get_coin_at_position(target_position) != null:
		return false

	var hero_spawner = get_tree().get_first_node_in_group("Hero_spawner") as HeroSpawner
	if hero_spawner != null and hero_spawner.hero != null and hero_spawner.get_hero_grid_position() == target_position:
		return false

	return true

func get_rat_at_position(target_position: Vector2, ignored_rat: Rat = null) -> Rat:
	for child in rats.get_children():
		var rat = child as Rat
		if rat == null or rat == ignored_rat:
			continue
		if rat.get_grid_position() == target_position:
			return rat
	return null

func get_coin_at_position(target_position: Vector2) -> Coin:
	for child in coins.get_children():
		var coin = child as Coin
		if coin != null and coin.get_grid_position() == target_position:
			return coin
	return null

func is_position_excluded(target_position: Vector2, excluded_positions: Array) -> bool:
	for excluded_position in excluded_positions:
		if excluded_position == target_position:
			return true
	return false

func is_inside_wall_bounds(target_position: Vector2) -> bool:
	return (
		target_position.x > walls.top_left_corner.x
		and target_position.x < walls.bottom_right_corner.x
		and target_position.y > walls.top_left_corner.y
		and target_position.y < walls.bottom_right_corner.y
	)
