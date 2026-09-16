class_name GridPositionComponent
extends Node

@export var actor: Node3D
@export var billboard_height :=0.5

var grid_position := Vector2.ZERO
func _ready() -> void:
	if actor == null:
		actor = get_parent() as Node3D
func set_grid_position( value: Vector2) -> void:
		grid_position = value
		
		if actor != null:
			actor.position = Vector3(
				value.x,
				billboard_height,
				value.y
			)
func get_grid_position() -> Vector2:
	return grid_position
