class_name Chest
extends Node3D

signal opened(
	actor: Node3D,
	grid_position: Vector2,
	dropped_item_scenes: Array[PackedScene]
)
@onready var grid: GridPositionComponent = $GridPositionComponent
@onready var health: HealthComponent = $HealthComponent
@onready var knockback: KnockbackComponent = $KnockbackComponent
@onready var drops: DropComponent = $DropComponent

var is_open := false

func configure(grid_occupancy: GridOccupancy) -> void:
	knockback.configure(grid_occupancy)
	
func receive_hit(amount: int, direction: Vector2) -> bool:
	if is_open:
		return false
	var was_depleted := health.take_damage(amount)
	knockback.apply(direction)
	if was_depleted:
		open(true)
		
	return was_depleted 
func try_open_with_key(party_inventory: Node) ->bool:
	if is_open or not party_inventory.has_method("consume_key"):
		return false
	open()
	return true
func open(after_knockback := false) -> void:
	if is_open:
		return
	is_open = true
	if after_knockback:
		await knockback.wait_until_animation_finishes()
	if not is_inside_tree():
		return
	opened.emit(self, grid.get_grid_position(), drops.roll_items())
	queue_free()
