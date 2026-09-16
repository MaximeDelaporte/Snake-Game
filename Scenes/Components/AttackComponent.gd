class_name AttackComponent
extends Node

@export var attack_shape: Array[Vector2] = [Vector2(0, 1)]
@export_range(0.0, 60.0, 0.05) var cooldown_seconds := 0.0

var heroes_party: HeroesParty
var world_clock: IncrementalTimer
var next_ready_time := 0.0

func configure(
	new_heroes_party: HeroesParty,
	new_world_clock: IncrementalTimer = null
) -> void:
	heroes_party = new_heroes_party
	world_clock = new_world_clock
	next_ready_time = get_current_time()

func is_ready() -> bool:
	return get_cooldown_remaining() <= 0.0

func get_cooldown_remaining() -> float:
	return maxf(0.0, next_ready_time - get_current_time())

func can_attack(
	target: Variant,
	origin_position: Vector2,
	forward_direction: Vector2
) -> bool:
	if not is_ready():
		return false
	if target == null or not is_instance_valid(target):
		return false
	var hero := target as Hero
	if hero == null:
		return false
	if heroes_party == null or not heroes_party.is_leader(hero):
		return false
	var target_position := heroes_party.get_actor_grid_position(hero)
	return can_attack_position(
		target_position,
		origin_position,
		forward_direction
	)

func can_attack_position(
	target_position: Vector2,
	origin_position: Vector2,
	forward_direction: Vector2
) -> bool:
	return (
		is_ready()
		and get_affected_positions(
			origin_position,
			forward_direction
		).has(target_position)
	)

func attack(
	target: Variant,
	origin_position: Vector2,
	forward_direction: Vector2
) -> bool:
	if not can_attack(target, origin_position, forward_direction):
		return false
	next_ready_time = get_current_time() + cooldown_seconds
	return heroes_party.get_hit(target as Hero)

func attack_actor(
	target: Variant,
	target_position: Vector2,
	origin_position: Vector2,
	forward_direction: Vector2,
	damage: int = 1,
	hit_direction: Vector2 = Vector2.ZERO
) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	if not target.has_method("receive_hit"):
		return false
	if not can_attack_position(
		target_position,
		origin_position,
		forward_direction
	):
		return false
	next_ready_time = get_current_time() + cooldown_seconds
	return bool(target.call("receive_hit", damage, hit_direction))

func get_current_time() -> float:
	if world_clock != null:
		return world_clock.elapsed_time
	return Time.get_ticks_msec() / 1000.0

func get_affected_positions(
	origin_position: Vector2,
	forward_direction: Vector2
) -> Array[Vector2]:
	var forward := to_cardinal_direction(forward_direction)
	var positions: Array[Vector2] = []
	if forward == Vector2.ZERO:
		return positions
	var right := Vector2(-forward.y, forward.x)
	for local_offset in attack_shape:
		positions.append(
			origin_position
			+ right * local_offset.x
			+ forward * local_offset.y
		)
	return positions

func to_cardinal_direction(direction: Vector2) -> Vector2:
	if direction == Vector2.ZERO:
		return Vector2.ZERO
	if absf(direction.x) >= absf(direction.y):
		return Vector2(signf(direction.x), 0)
	return Vector2(0, signf(direction.y))
