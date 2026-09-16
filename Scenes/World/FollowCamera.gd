class_name FollowCamera

extends Camera3D

@export var target_path: NodePath
@export var follow_distance := 7.0
@export var follow_height := 5.5
@export var look_ahead := 2.0
@export var look_height := 1.0
@export var smoothing := 7.0
@export var focus_smoothing := 10.0
@export var vertical_focus_smoothing := 4.0
@export var vertical_follow_amount := 0.35

var target: HeroesParty
var current_forward := Vector3(0, 0, 1)
var smoothed_focus_position := Vector3.ZERO

func _ready() -> void:
	target = get_node_or_null(target_path) as HeroesParty
	if target != null:
		smoothed_focus_position = get_focus_position()
		global_position = get_desired_position()
		look_at(get_look_target(), Vector3.UP)

func _process(delta: float) -> void:
	if target == null:
		target = get_node_or_null(target_path) as HeroesParty
		if target == null:
			return

	var target_forward = target.get_forward_world_direction()
	current_forward = current_forward.slerp(target_forward, min(delta * smoothing, 1.0)).normalized()
	update_focus_position(delta)
	global_position = global_position.lerp(get_desired_position(), min(delta * smoothing, 1.0))
	look_at(get_look_target(), Vector3.UP)

func get_desired_position() -> Vector3:
	return smoothed_focus_position - current_forward * follow_distance + Vector3.UP * follow_height

func get_look_target() -> Vector3:
	return smoothed_focus_position + current_forward * look_ahead + Vector3.UP * look_height

func get_focus_position() -> Vector3:
	var leader_focus = target.get_camera_focus_position()
	var base_focus = target.get_camera_base_focus_position()
	return base_focus.lerp(leader_focus, vertical_follow_amount)

func update_focus_position(delta: float) -> void:
	var focus_position = get_focus_position()
	smoothed_focus_position.x = lerpf(smoothed_focus_position.x, focus_position.x, min(delta * focus_smoothing, 1.0))
	smoothed_focus_position.z = lerpf(smoothed_focus_position.z, focus_position.z, min(delta * focus_smoothing, 1.0))
	smoothed_focus_position.y = lerpf(smoothed_focus_position.y, focus_position.y, min(delta * vertical_focus_smoothing, 1.0))
