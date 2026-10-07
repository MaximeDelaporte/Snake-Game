@tool
class_name RoomGeometryBuilder
extends Node

func geometry_for(playable_size: Vector2i) -> Dictionary:
	assert(playable_size.x > 0 and playable_size.x % 2 == 1)
	assert(playable_size.y > 0 and playable_size.y % 2 == 1)
	var hx := (playable_size.x - 1) /2
	var hz := (playable_size.y - 1) /2
	return {
		"floor_size": Vector3(playable_size.x, 0.2, playable_size.y),
		"socket_positions": {
			DungeonDirection.NORTH: Vector3(0,0,-hz),
			DungeonDirection.EAST: Vector3(hx, 0,0),
			DungeonDirection.SOUTH: Vector3(0,0,hz),
			DungeonDirection.WEST: Vector3(-hx, 0,0)
		},
		"playable_half_extents" : Vector2(hx, hz),
		"boundary_outer_half_extends" : Vector2(hx +1, hz +1),
		"boundary_segment_sizes": {
			"north_south": Vector3(hx+1, 2, 1),
			"east_west" : Vector3(1,2, hz)
		}
		
	}
