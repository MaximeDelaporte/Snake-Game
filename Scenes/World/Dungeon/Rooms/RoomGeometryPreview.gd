@tool
extends Node

@export var playable_size := Vector2i(21,29):
	set(value):
		playable_size = value
		if Engine.is_editor_hint() and is_inside_tree():
			_print_geometry()
func _ready() -> void:
	if Engine.is_editor_hint():
		_print_geometry()
func _print_geometry() -> void:
	var geometry := RoomGeometryBuilder.new().geometry_for(playable_size)
	print('Room geometry: ' , geometry)
