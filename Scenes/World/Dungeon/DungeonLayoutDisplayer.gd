extends Node

func print_seed(seed_value: int) -> void:
	print("Dungeon generation seed ", seed_value)
func print_maint_path(
	coordinates: Array[Vector2i],
	grid_size: Vector2i,
	seed_value: int
) -> void:
	print("Main path seed: ", seed_value)
	for y in range(grid_size.y -1, -1, -1):
		var row := ""
		for x in range(grid_size.x):
			var coordinate= Vector2i(x,y)
			var index := coordinates.find(coordinate)
			if index < 0:
				row += "."
			elif index ==0:
				row += "E"
			elif index == coordinates.size():
				row += "0"
			else:
				row += 'M'
		print(row)
