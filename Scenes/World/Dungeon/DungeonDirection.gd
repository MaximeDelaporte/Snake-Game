class_name DungeonDirection
extends RefCounted

const NORTH := Vector2i.UP
const EAST := Vector2i.RIGHT
const SOUTH := Vector2i.DOWN
const WEST := Vector2i.LEFT

const CARDINALS: Array[Vector2i] = [
	NORTH,EAST,SOUTH,WEST
]

static func opposite(direction: Vector2i) -> Vector2i:
	return -direction
