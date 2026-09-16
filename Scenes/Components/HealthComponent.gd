class_name HealthComponent
extends Node

signal damaged(amount: int, remaining_hit_points: int)
signal depleted

@export var max_hit_points := 1

var hit_points := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
func reset() -> void:
	hit_points = maxi(1, max_hit_points)
func take_damage(amount: int) -> bool:
	if amount <= 0 or hit_points <= 0:
		return false
	hit_points = maxi(0, hit_points - amount)
	damaged.emit(amount, hit_points)
	if hit_points == 0:
		depleted.emit()
		return true
	return false
