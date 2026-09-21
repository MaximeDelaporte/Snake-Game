extends Node

signal swiped(direction: Vector2)

@export_range(8.0,160.0,1.0)
var minimum_swipe_distance := 48.0

var active_finger := -1
var start_position := Vector2.ZERO
var last_direction := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and not event.is_canceled() and active_finger == -1:
			active_finger = event.index
			start_position = event. position
			last_direction = Vector2.ZERO
			get_viewport().set_input_as_handled()
func _input(event: InputEvent) -> void:
	if active_finger == -1:
		return
	if event is InputEventScreenDrag and event.index ==active_finger:
		try_swipe(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.index == active_finger:
		if event.is_canceled():
			reset_gesture()
		elif not event.is_pressed():
			try_swipe(event.position)
			reset_gesture()
		get_viewport().set_input_as_handled()
func try_swipe(position: Vector2) -> void:
	var displacement := position - start_position
	if displacement.length() < minimum_swipe_distance:
		return
	var direction: Vector2
	if absf(displacement.x) > absf(displacement.y):
		direction = Vector2(signf(displacement.x), 0.0)
	else:
		direction = Vector2(0.0, signf(displacement.y))
	start_position = position
	if direction == last_direction:
		return
	last_direction = direction
	swiped.emit(direction)

func reset_gesture() -> void:
	active_finger = -1
	last_direction = Vector2.ZERO

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		reset_gesture()
