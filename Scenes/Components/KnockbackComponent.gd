class_name KnockbackComponent
extends Node

@export var grid_position: GridPositionComponent

@export_range(0, 10,1)
var maximum_distance :=1

@export_range(0.0,0.5,0.01)
var animation_seconds_per_space := 0.06

var grid_occupancy: GridOccupancy
var active_tween: Tween

func configure(new_grid_occupancy: GridOccupancy) -> void:
	grid_occupancy = new_grid_occupancy
func apply(direction: Vector2) -> int:
	var knockback_direction := to_cardinal_direction(direction)
	if (
		knockback_direction == Vector2.ZERO
		or maximum_distance <= 0
		or grid_occupancy == null
		or grid_position == null
		or grid_position.actor == null
	):
		return 0
	var actor := grid_position.actor
	var visual_start := actor.position
	var moved_spaces := 0
	for _step in range (maximum_distance):
		var target := (grid_position.get_grid_position() + knockback_direction)
		var is_free := grid_occupancy.is_grid_position_free(target, get_parent())
		if not is_free:
			break
		grid_position.set_grid_position(target)
		moved_spaces += 1
	if moved_spaces > 0 and animation_seconds_per_space > 0.0:
		var visual_destination := actor.position
		actor.position = visual_start
		if active_tween != null and active_tween.is_valid():
			active_tween.kill()
		active_tween = create_tween()
		active_tween.set_trans(Tween.TRANS_QUAD)
		active_tween.set_ease(Tween.EASE_OUT)
		active_tween.tween_property(
			actor,"position", visual_destination, animation_seconds_per_space * moved_spaces
		)
	return moved_spaces
func wait_until_animation_finishes() -> void:
	if active_tween != null and active_tween.is_running():
		await active_tween.finished
func to_cardinal_direction(direction: Vector2) -> Vector2:
	if direction == Vector2.ZERO:
		return direction
	if absf(direction.x) >= absf(direction.y):
		return Vector2(signf(direction.x), 0)
	return Vector2(0, signf(direction.y))
