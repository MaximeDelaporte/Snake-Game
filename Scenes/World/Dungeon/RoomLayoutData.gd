class_name RoomLayoutData
extends RefCounted

enum Role {
	ENTRANCE,
	MAIN,
	BOSS,
	EXIT,
	BRANCH,
	BRANCH_REWARD,
}

enum EncounterKind {
	NONE,
	COMBAT,
	CHALLENGE,
	BOSS
}

var id := -1
var coordinate := Vector2i.ZERO
var role := Role.MAIN
var encounter_kind := EncounterKind.NONE
var main_path_index := -1
var branch_depth := 0
var parent_id := -1
var neighbor_ids : Dictionary = {}
var difficulty_tier := 0
var reward_tier := 0

func connect_room(direction: Vector2i, other_id: int) -> void:
	neighbor_ids[direction] = other_id 
func has_neighor(direction: Vector2i) -> bool:
	return neighbor_ids.has(direction)
