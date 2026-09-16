class_name TiledFloor

extends Node3D

@export var width := 22
@export var depth := 30
@export var tile_height := 0.375
@export var material: Material

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	for child in get_children():
		child.queue_free()

	var mesh = BoxMesh.new()
	mesh.size = Vector3(width, tile_height, depth)

	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = mesh
	floor_mesh.material_override = material
	add_child(floor_mesh)
