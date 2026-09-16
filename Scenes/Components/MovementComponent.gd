class_name MovementComponent
extends Node

@export var grid_position: GridPositionComponent

var grid_occupancy: GridOccupancy
var world_clock: IncrementalTimer

func configure(new_grid_occupancy: GridOccupancy,new_world_clock: IncrementalTimer) -> void :
	grid_occupancy = new_grid_occupancy
	world_clock = new_world_clock

func move_steps(direction: Vector2, step_count: int, speed_multiplier := 1.0) -> void:
	if direction == Vector2.ZERO or not is_inside_tree():
		return
	var step_interval := get_step_interval() /maxf(0.01, speed_multiplier)
	for step in range(step_count):
		if not is_inside_tree():
			return
		var target := grid_position.get_grid_position() + direction
		if not can_move_to(target):
			return
		grid_position.set_grid_position(target)
		if step < step_count - 1:
			await wait_world_seconds(step_interval)
func can_move_to(target: Vector2)->bool:
	return(
		grid_occupancy != null
		and grid_occupancy.is_grid_position_free(target, get_parent())
	)
func get_random_direction() -> Vector2:
	var directions: Array[Vector2] = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]
	directions.shuffle()
	
	for direction in directions:
		if can_move_to(grid_position.get_grid_position() + direction):
			return direction
	return Vector2.ZERO
	
func get_step_interval() -> float:
	return 0.2
func wait_world_seconds(duration: float) -> void:
	if world_clock != null:
		await world_clock.wait_seconds(duration)
		return
	var tree := get_tree()
	if tree != null:
		await tree.create_timer(duration).timeout
