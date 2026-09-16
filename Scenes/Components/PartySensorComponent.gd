class_name PartySensorComponent
extends Node

enum TargetPosition {
	LEADER,
	FRONT,
	BACK,
	LEFT_SIDE,
	RIGHT_SIDE,
	CLOSEST_SIDE,
}

@export var grid_position: GridPositionComponent

var heroes_party: HeroesParty

func configure(new_heroes_party: HeroesParty) -> void:
	heroes_party = new_heroes_party
func get_leader() -> Hero:
	if heroes_party == null:
		return null
	return heroes_party.get_leader()
func get_leader_position() -> Vector2:
	if heroes_party == null:
		return grid_position.get_grid_position()
	return heroes_party.get_leader_grid_position()
func get_leader_direction() -> Vector2:
	if heroes_party == null:
		return Vector2.DOWN
	return heroes_party.get_leader_direction()
func get_target_position(target_type: TargetPosition) -> Vector2:
	var leader_position := get_leader_position()
	var forward := get_leader_direction()
	var right := Vector2(-forward.y, forward.x)
	match target_type:
		TargetPosition.FRONT:
			return leader_position + forward
		TargetPosition.BACK:
			return leader_position - forward
		TargetPosition.LEFT_SIDE:
			return leader_position - right
		TargetPosition.RIGHT_SIDE:
			return leader_position + right
		TargetPosition.CLOSEST_SIDE:
			return get_closest_position([
				leader_position - right,leader_position + right
			])
	return  leader_position
func get_closest_position(positions: Array[Vector2]) -> Vector2:
	var origin := grid_position.get_grid_position()
	var closest := origin
	var closest_distance := INF
	
	for candidate in positions:
		var distance := get_grid_distance(origin, candidate)
		if distance < closest_distance:
			closest_distance = distance
			closest = candidate
	return closest
func get_grid_distance(a: Vector2, b: Vector2) -> float:
	return absf(a.x - b.x) + absf(a.y - b.y)
func is_leader_within_distance(max_distance: float) -> bool:
	if get_leader() == null:
		return false
	return get_grid_distance(
		grid_position.get_grid_position(),
		get_leader_position()
	) <= max_distance
