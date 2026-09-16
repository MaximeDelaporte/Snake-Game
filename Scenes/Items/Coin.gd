class_name Coin

extends Node3D

const BILLBOARD_HEIGHT := 0.5
@export var points :=10
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	sprite.texture = preload("res://Assets/Images/Characters/Items/coin_placeholder.png")
	add_to_group("Coins")

func set_grid_position(grid_position: Vector2) -> void:
	set_meta("grid_position", grid_position)
	position = Vector3(grid_position.x, BILLBOARD_HEIGHT, grid_position.y)

func get_grid_position() -> Vector2:
	if has_meta("grid_position"):
		return get_meta("grid_position") as Vector2
	return Vector2(position.x, position.z)
func collect(collector: Node) -> void:
	if collector != null and collector.has_method('add_points'):
		collector.call("add_points", points)
