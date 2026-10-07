class_name DungeonGenerator
extends Node

var _rng: RandomNumberGenerator
func _initialize_rng(seed_value: int) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value
func shuffled_directions() -> Array[Vector2i]:
	var result := DungeonDirection.CARDINALS.duplicate()
	for index in range(result.size() -1, 0, -1):
		var swap_index := _rng.randi_range(0, index)
		var value :Vector2i = result[index]
		result[index] = result[swap_index]
		result[swap_index] = value
	return result
func _shuffle(values: Array) -> void:
	for index in range(values.size() -1, 0, -1):
		_swap(values, index, _rng.randi_range(0, index))
func _swap(values: Array, first:int, second: int) -> void:
	var temporary = values[first]
	values[first] = values[second]
	values[second] = temporary
func is_inside_dungeon_grid(
	coordinate: Vector2i,
	grid_size: Vector2i
)-> bool:
	return (
		coordinate.x >= 0
		and coordinate.y >= 0
		and coordinate.x < grid_size.x
		and coordinate.y < grid_size.y
	)
func carve_path(
	coordinates: Array[Vector2i],
	occupied: Dictionary,
	target_room_count: int,
	previous_direction: Vector2i,
	straight_run: int,
	turn_count: int,
	settings: DungeonGenerationSettings,
)-> bool:
	if coordinates.size() == target_room_count:
		return turn_count >= settings.minimum_main_path_turns
	var current := coordinates[-1]
	for direction in shuffled_directions():
		var candidate := current + direction
		if not is_inside_dungeon_grid(candidate, settings.dungeon_grid_size):
			continue
		if occupied.has(candidate):
			continue
		var changed_direction := (
			previous_direction != Vector2i.ZERO
			and direction != previous_direction
		)
		var next_straight_run := (
			1 if changed_direction
			else straight_run +1
		)
		if next_straight_run > settings.maximum_straight_run:
			continue
		var next_turn_count := (
			turn_count + 1 if changed_direction
			else turn_count
		)
		occupied[candidate] = true
		coordinates.append(candidate)
		if carve_path(
			coordinates,
			occupied,
			target_room_count,
			direction,
			next_straight_run,
			next_turn_count,
			settings,
		):
			return true
		coordinates.pop_back()
		occupied.erase(candidate)
	return false
func carve_main_path(
	settings: DungeonGenerationSettings
) -> Array[Vector2i]:
	var entrance := Vector2i(_rng.randi_range(0, settings.dungeon_grid_size.x -1),_rng.randi_range(0, settings.dungeon_grid_size.y -1))
	var coordinates: Array[Vector2i] = [entrance]
	var occupied: Dictionary = {entrance: true}
	var target_room_count := settings.entrance_to_exit_transitions +1
	var carved := carve_path(
		coordinates,
		occupied,
		target_room_count,
		Vector2i.ZERO,
		0,
		0,
		settings
	)
	return coordinates if carved else []
func add_branches(
	layout: DungeonLayout,
	main_ids: Array[int],
	occupied: Dictionary,
	settings: DungeonGenerationSettings
) -> bool:
	var anchors: Array[int] = []
	for room_id in main_ids:
		var room := layout.rooms_by_id[room_id] as RoomLayoutData
		if room.role == RoomLayoutData.Role.MAIN:
			anchors.append(room_id)
		_shuffle(anchors)
		if anchors.size() < settings.branch_count:
			return false
		for branch_index in range(settings.branch_count):
			if not try_add_branch(
				layout,
				anchors[branch_index],
				occupied,
				settings
			): return false
	return true
func try_add_branch(
	layout: DungeonLayout,
	anchor_id: int,
	occupied: Dictionary,
	settings: DungeonGenerationSettings
)-> bool:
	var anchor := layout.rooms_by_ids[anchor_id] as RoomLayoutData
	var lengths: Array[int] = []
	for length in range(
		settings.minimum_branch_length, settings.maximum_branch_length +1
	):
		lengths.append(length)
	_shuffle(lengths)
	for length in lengths:
		var branch_coordinates : Array[Vector2i] = [anchor.coordinate]
		if not carve_branch_coordinates(
			branch_coordinates,
			occupied,
			length,
			settings
		):
			continue
		var previous_id := anchor_id
		for depth in range(1, branch_coordinates.size()):
			var room := RoomLayoutData.new()
			room.coordinate = branch_coordinates[depth]
			room.role = (
				RoomLayoutData.Role.BRANCH_REWARD
				if depth == length
				else RoomLayoutData.Role.BRANCH
			)
			room.main_path_index = anchor.main_path_index
			room.branch_depth = depth
			room.parent_id = previous_id
			layout.add_room(room)
			layout.connect_room(previous_id, room.id)
			previous_id = room.id
		return true
	return false
func carve_branch_coordinates(
	coordinates: Array[Vector2i],
	occupied: Dictionary,
	target_length: int,
	settings: DungeonGenerationSettings
)-> bool:
	if coordinates.size() -1 == target_length:
		return true
	for direction in shuffled_directions():
		var candidate := coordinates[-1] + direction
		if not is_inside_dungeon_grid(
			candidate,
			settings.dungeon_grid_size
		)or occupied.has(candidate):
			continue
		occupied[candidate] = true
		coordinates.append(candidate)
		if carve_branch_coordinates(
			coordinates,
			occupied,
			target_length,
			settings
		):
			return true
		coordinates.pop_back()
		occupied.erase(candidate)
	return false
func print_layout_graph(layout: DungeonLayout)->void:
	print("Dungeon seed: ", layout.seed_value)
	var room_ids: Array[int] = []
	for value in layout.rooms_by_ids.keys():
		room_ids.append(value as int)
	room_ids.sort()
	for room_id in room_ids:
		var room := layout.rooms_by_ids[room_id] as RoomLayoutData
		var connections: Array[String] = []
		for direction in DungeonDirection.CARDINALS:
			if room.neighbor_ids.has(direction):
				connections.append("%s => %d" % [direction, room.neighbor_ids[direction]])
		print( "Room %d: plot=%s role=%d parent=+d | %s"
		% [
			room.id,
			room.coordinate,
			room.role,
			room.parent_id,
			", ".join(connections),
		])
