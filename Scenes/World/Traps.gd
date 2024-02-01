class_name Traps

extends Node

var traps_dict = {}

func _ready():
	var traps = get_tree().get_nodes_in_group('Traps') as Array[Node2D]
	var index = 0
	for trap in traps:
		traps_dict[index] = trap.position
		index += 1
func is_on_trap_position(position: Vector2) :
	for trap in traps_dict:
		if position == traps_dict[trap]:
			return true
	return false
