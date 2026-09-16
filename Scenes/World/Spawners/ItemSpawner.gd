class_name ItemSpawner
extends Node3D

@onready var items: Node3D = $Items

func spawn_item(
	item_scene: PackedScene,
	grid_position: Vector2
) -> Node3D:
	if item_scene == null or get_item_at_position(grid_position) != null:
		return null
	var item := item_scene.instantiate() as Node3D
	if item == null:
		return null
	items.add_child(item)
	if item.has_method("set_grid_position"):
		item.call("set_grid_position", grid_position)
	return item
func get_item_at_position(grid_position: Vector2) -> Node3D:
	for child in items.get_children():
		var item := child as Node3D
		if (
			item != null
			and item.has_method("get_grid_position")
			and item.call("get_grid_position") == grid_position
		):
			return item
	return null
func collect_item_at_position(
	grid_position: Vector2,
	collector: Node
)-> bool:
	var item := get_item_at_position(grid_position)
	if item == null:
		return false
	if not item.has_method("collect"):
		push_warning("Dropped item does not implement collect(collector)")
		return false
	item.call("collect", collector)
	if not is_instance_valid(item):
		return true
	if item.get_parent() == items:
		items.remove_child(item)
	item.queue_free()
	
	return true
