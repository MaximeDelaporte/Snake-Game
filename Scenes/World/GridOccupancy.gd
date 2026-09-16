class_name GridOccupancy
extends Node

@export var walls: Walls
@export var traps: Traps
@export var heroes_party: HeroesParty
@export var hero_spawner: HeroSpawner
@export var blocking_roots: Array[Node] = []

func is_grid_position_free(
	target_position: Vector2,
	ignored_actor: Node3D = null,
	excluded_positions: Array = []
)-> bool:
	if not is_inside_wall_bounds(target_position):
		return false
	if traps != null and traps.is_on_trap_position(target_position):
		return false
	if heroes_party != null:
		if target_position == heroes_party.grid_position :
			return false
		if heroes_party.has_hero_on_grid_position(target_position):
			return false
	if excluded_positions.has(target_position):
		return false
	if (
		hero_spawner != null
		and hero_spawner.hero != null
		and hero_spawner.get_hero_grid_position() == target_position
	):
		return false
	if get_blocking_actor_at_position(target_position, ignored_actor) != null:
		return false
	return true
func is_inside_wall_bounds(target_position: Vector2) -> bool:
	return (
		walls != null
		and target_position.x > walls.top_left_corner.x
		and target_position.x < walls.bottom_right_corner.x
		and target_position.y > walls.top_left_corner.y
		and target_position.y < walls.bottom_right_corner.y
	)
func get_blocking_actor_at_position(
	target_position: Vector2,
	ignored_actor: Node3D = null
)-> Node3D:
	for root in blocking_roots:
		if root== null:
			continue
		var blocker := find_blocker_recursive(
			root,
			target_position,
			ignored_actor
		)
		if blocker != null:
			return blocker
	return null
func find_blocker_recursive(
	node: Node, 
	target_position: Vector2,
	ignored_actor: Node3D
) -> Node3D:
	var actor := node as Node3D
	if actor != null and actor != ignored_actor:
		var grid := actor.get_node_or_null(
			"GridPositionComponent"
		) as GridPositionComponent
		if grid != null and grid.get_grid_position() == target_position:
			return actor
		if (
			grid == null
			and actor.has_method('get_grid_position')
			and actor.call('get_grid_position') == target_position
		):
			return actor
	for child in node.get_children():
		var blocker := find_blocker_recursive(
			child,
			target_position,
			ignored_actor
		)
		if blocker != null:
			return blocker
	return null
		
