class_name DropComponent
extends Node

@export_range(0.0, 1.0, 0.01)
var drop_chance := 0.0

@export var item_scenes: Array[PackedScene]

func roll_items() -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	for item_scene in item_scenes:
		if item_scene != null and randf() < drop_chance:
			result.append(item_scene)
	return result
