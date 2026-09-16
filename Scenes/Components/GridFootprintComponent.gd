class_name GridFootprintComponent
extends Node

@export var grid_position: GridPositionComponent
@export var local_cells: Array[Vector2] = [Vector2.ZERO]

func get_cells_at(origin: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for local_cell in local_cells:
		result.append(origin + local_cell)
	return result
func get_occupied_cells() -> Array[Vector2]:
	return get_cells_at(grid_position.get_grid_position())
func contains(target_position: Vector2) -> bool:
	return get_occupied_cells().has(target_position)
