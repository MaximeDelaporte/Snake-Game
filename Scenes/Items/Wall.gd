class_name Wall

extends Node3D

const WALL_SIDE_MESH: Mesh = preload("res://Assets/Wall_side.obj")
const WALL_CORNER_MESH: Mesh = preload("res://Assets/Wall_corner.obj")
const WALL_UNIT := 1.0
const HALF_WALL_UNIT := WALL_UNIT * 0.5

@export var segment_height := 2.5
@export var wall_thickness := 0.35
@export var material: Material
@export var add_end_corners := false
@export var corner_yaw_offset_degrees := 180.0

@onready var segments: Node3D = $Segments

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	for child in segments.get_children():
		child.queue_free()

	var count_x = max(1, int(round(scale.x)))
	var count_z = max(1, int(round(scale.z)))
	if count_x >= count_z:
		add_horizontal_wall(count_x)
	else:
		add_vertical_wall(count_z)

	scale = Vector3.ONE

func add_horizontal_wall(length_units: int) -> void:
	var z_offset = signf(position.z) * HALF_WALL_UNIT
	var side_rotation = get_horizontal_side_rotation()
	var side_scale = get_side_instance_scale()
	var side_count = get_side_count(length_units)
	var start_x = get_horizontal_side_start_x(length_units)
	for index in range(side_count):
		var wall_mesh = create_mesh_instance(WALL_SIDE_MESH)
		wall_mesh.position = Vector3(start_x + index, 0.0, z_offset)
		wall_mesh.rotation.y = side_rotation
		wall_mesh.scale = side_scale
		segments.add_child(wall_mesh)

	if not add_end_corners:
		return

	add_corner(
		Vector3(get_horizontal_corner_x(length_units), 0.0, z_offset),
		get_horizontal_corner_rotation()
	)

func add_vertical_wall(length_units: int) -> void:
	var x_offset = signf(position.x) * HALF_WALL_UNIT
	var side_rotation = get_vertical_side_rotation()
	var side_scale = get_side_instance_scale()
	var side_count = get_side_count(length_units)
	var start_z = get_vertical_side_start_z(length_units)
	for index in range(side_count):
		var wall_mesh = create_mesh_instance(WALL_SIDE_MESH)
		wall_mesh.position = Vector3(x_offset, 0.0, start_z + index)
		wall_mesh.rotation.y = side_rotation
		wall_mesh.scale = side_scale
		segments.add_child(wall_mesh)

	if not add_end_corners:
		return

	add_corner(
		Vector3(x_offset, 0.0, get_vertical_corner_z(length_units)),
		get_vertical_corner_rotation()
	)

func add_corner(local_position: Vector3, y_rotation: float) -> void:
	var corner_mesh = create_mesh_instance(WALL_CORNER_MESH)
	corner_mesh.position = local_position
	corner_mesh.rotation.y = y_rotation + deg_to_rad(corner_yaw_offset_degrees)
	corner_mesh.scale = get_corner_instance_scale()
	segments.add_child(corner_mesh)

func create_mesh_instance(mesh: Mesh) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	return mesh_instance

func get_side_instance_scale() -> Vector3:
	var side_size = WALL_SIDE_MESH.get_aabb().size
	return Vector3(
		WALL_UNIT / side_size.x,
		segment_height / side_size.y,
		WALL_UNIT / side_size.z
	)

func get_corner_instance_scale() -> Vector3:
	var corner_size = WALL_CORNER_MESH.get_aabb().size
	return Vector3(
		WALL_UNIT / corner_size.x,
		segment_height / corner_size.y,
		WALL_UNIT / corner_size.z
	)

func get_horizontal_side_rotation() -> float:
	if position.z < 0.0:
		return PI
	return 0.0

func get_vertical_side_rotation() -> float:
	if position.x < 0.0:
		return PI * 0.5
	return PI * 1.5

func get_side_count(length_units: int) -> int:
	if not add_end_corners:
		return length_units
	return max(0, length_units - 1)

func get_horizontal_side_start_x(length_units: int) -> float:
	var first_slot = -((length_units - 1) * 0.5)
	if not add_end_corners:
		return first_slot
	if is_top_wall():
		return first_slot
	return first_slot + 1.0

func get_vertical_side_start_z(length_units: int) -> float:
	var first_slot = -((length_units - 1) * 0.5)
	if not add_end_corners:
		return first_slot
	if is_right_wall():
		return first_slot
	return first_slot + 1.0

func get_horizontal_corner_x(length_units: int) -> float:
	var first_slot = -((length_units - 1) * 0.5)
	if is_top_wall():
		return first_slot + length_units - 1
	return first_slot

func get_vertical_corner_z(length_units: int) -> float:
	var first_slot = -((length_units - 1) * 0.5)
	if is_right_wall():
		return first_slot + length_units - 1
	return first_slot

func get_horizontal_corner_rotation() -> float:
	if is_top_wall():
		return 0.0
	return PI

func get_vertical_corner_rotation() -> float:
	if is_right_wall():
		return PI * 0.5
	return PI * 1.5

func is_top_wall() -> bool:
	return position.z < 0.0

func is_right_wall() -> bool:
	return position.x > 0.0
