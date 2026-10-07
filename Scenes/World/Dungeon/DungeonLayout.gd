class_name DungeonLayout
extends RefCounted

var seed_value := {}
var rooms_by_ids: Dictionary = {}
var room_id_by_coordinate: Dictionary = {}
var entrance_id := -1
var exit_id := -1

func add_room(room: RoomLayoutData) -> bool:
	if room_id_by_coordinate.has(room.coordinate):
		return false
	rooms_by_ids[room.id] = room
	room_id_by_coordinate[room.coordinate] = room.id
	return true
func connect_room(room_a_id: int, room_b_id:int) -> void:
	var room_a := rooms_by_ids[room_a_id] as RoomLayoutData
	var room_b := rooms_by_ids[room_b_id] as RoomLayoutData
	var direction := room_b.coordinate - room_a.coordinate
	assert(DungeonDirection.CARDINALS.has(direction))
	room_a.connect_room(direction, room_b_id)
	room_b.connect_room(-direction, room_a_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
