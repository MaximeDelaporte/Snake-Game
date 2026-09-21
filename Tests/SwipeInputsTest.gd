extends SceneTree

const SwipeInputScript = preload("res://Scenes/Components/SwipeInput.gd")
var gestures: Array[Vector2] = []

func _initialize() -> void:
	call_deferred("run_check")
func run_check() -> void:
	var input := SwipeInputScript.new()
	root.add_child(input)
	input.swiped.connect(func(direction: Vector2): gestures.append(direction))
	
	input._unhandled_input(touch(true, Vector2.ZERO))
	input._input(drag(Vector2(5,2)))
	input._input(touch(false, Vector2(5,2)))
	assert(gestures.is_empty())
	
	input._unhandled_input(touch(true, Vector2.ZERO))
	input._unhandled_input(touch(true, Vector2.ZERO, 1))
	input._input(drag(Vector2(100,0), 1))
	input._input(touch(false, Vector2.ZERO, 1))
	assert(input.active_finger == 0 and gestures.is_empty())
	input._input(drag(Vector2(100, 10)))
	input._input(drag(Vector2(150, 10)))
	assert(gestures == [Vector2.RIGHT])
	input._input(drag(Vector2(100, 200)))
	input._input(touch(false, Vector2(100,200)))
	assert(gestures == [Vector2.RIGHT, Vector2.DOWN])
	
	for direction in [Vector2.UP, Vector2.LEFT,Vector2.DOWN] :
		input._unhandled_input(touch(true, Vector2.ZERO))
		input._input(touch(false, direction * 100.0))
	assert(gestures == [Vector2.RIGHT, Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
	
	input._unhandled_input(touch(true, Vector2.ZERO))
	input._input(drag(Vector2(input.minimum_swipe_distance - 1.0, 0)))
	assert(gestures.size() == 5)
	input._input(drag(Vector2(input.minimum_swipe_distance, 0)))
	assert(gestures.size() == 6 and gestures[-1] == Vector2.RIGHT)
	input._input(touch(false, Vector2(input.minimum_swipe_distance, 0)))
	
	input._unhandled_input(touch(true, Vector2.ZERO))
	var cancelled := touch(false, Vector2(100, 0))
	cancelled.canceled = true
	input._input(cancelled)
	assert(input.active_finger == -1 and gestures.size() == 6)
	
	input._unhandled_input(touch(true, Vector2.ZERO))
	paused = true
	assert(input.active_finger == -1)
	paused = false
	input._unhandled_input(touch(true, Vector2.ZERO))
	input._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(input.active_finger == -1)
	
	input.free()
	print("Swipe input checks passed")
	quit()
	
	
func touch(pressed: bool, position: Vector2, index: int = 0) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = position
	event.index = index
	return event
func drag(position: Vector2, index: int = 0) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.position = position
	event.index = index
	return event
