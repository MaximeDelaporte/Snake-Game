class_name Rat
extends Node3D

signal defeated(
	actor: Node3D,
	grid_position: Vector2,
	dropped_item_scenes: Array[PackedScene]
)

const NEAR_DISTANCE := 4
const FLEE_STEPS := 3
const FLEE_SPEED_MULTIPLIER := 2.0

@onready var sprite: Sprite3D = $Sprite3D
@onready var grid: GridPositionComponent = $GridPositionComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var sensor: PartySensorComponent = $PartySensorComponent
@onready var health: HealthComponent = $HealthComponent
@onready var knockback: KnockbackComponent = $KnockbackComponent
@onready var drops: DropComponent = $DropComponent

var active := false
var world_clock: IncrementalTimer

func _ready() -> void:
	sprite.texture = preload("res://Assets/Images/Characters/Ennemies/rat_placeholder.png")
	add_to_group("NPCs")
	add_to_group("Enemies")
	add_to_group("Rats")
func configure(
	heroes_party: HeroesParty,
	new_world_clock: IncrementalTimer,
	grid_occupancy: GridOccupancy
)-> void:
	world_clock = new_world_clock
	sensor.configure(heroes_party)
	movement.configure(grid_occupancy, world_clock)
	knockback.configure(grid_occupancy)
	
func activate() -> void:
	if active:
		return
	active = true
	behavior_loop()
func behavior_loop() -> void:
	while active and is_inside_tree():
		if should_flee_from_leader():
			await take_flee_turn()
			if not active or not is_inside_tree():
				return
			await movement.wait_world_seconds(randf_range(0.25,0.75))
			continue
		await take_wander_turn()
		if not active or not is_inside_tree():
			return
		await wait_for_detection_or_timeout(
			randf_range(0.5, 1.5)
		)
func take_turn() -> float:
	if sensor.get_leader() == null or not is_inside_tree():
		return 1.0
	var leader_position := sensor.get_leader_position()
	if sensor.is_leader_within_distance(NEAR_DISTANCE - 1):
		await movement.move_steps(
			get_flee_direction(leader_position),
			FLEE_STEPS,
			FLEE_SPEED_MULTIPLIER
		)
		return randf_range(0.25,0.75)
	await movement.move_steps(
		movement.get_random_direction(),
		randi_range(1,2)
	)
	return randf_range(0.5,1.5)
func should_flee_from_leader() -> bool:
	return (
		sensor.get_leader() != null
		and sensor.is_leader_within_distance(NEAR_DISTANCE -1)
	)
func take_flee_turn() -> void:
	var learder_position := sensor.get_leader_position()
	await movement.move_steps(
		get_flee_direction(learder_position),
		FLEE_STEPS,
		FLEE_SPEED_MULTIPLIER
	)
func take_wander_turn() -> void:
	await movement.move_steps(
		movement.get_random_direction(),
		randi_range(1,2)
	)
func wait_for_detection_or_timeout(duration: float) -> void:
	if should_flee_from_leader():
		return
	if world_clock == null:
		await movement.wait_world_seconds(duration)
		return
	var deadline := world_clock.elapsed_time + maxf(0.0, duration)
	while(
		active
		and is_inside_tree()
		and world_clock.elapsed_time < deadline
	):
		if should_flee_from_leader():
			return
		await world_clock.advanced
func get_flee_direction(leader_position: Vector2) -> Vector2:
	var delta = grid.get_grid_position() - leader_position
	var horizontal := Vector2(signf(delta.x), 0)
	var vertical := Vector2(0, signf(delta.y))
	var preferred_directions: Array[Vector2]

	if absf(delta.x) >= absf(delta.y):
		preferred_directions = [horizontal, vertical]
	else:
		preferred_directions = [vertical, horizontal]

	for direction in preferred_directions:
		if direction != Vector2.ZERO and movement.can_move_to(grid.get_grid_position() + direction):
			return direction

	return movement.get_random_direction()

func receive_hit(amount: int, direction: Vector2) -> bool:
	var was_depleted := health.take_damage(amount)
	knockback.apply(direction)
	if was_depleted:
		defeat()
	return was_depleted
func defeat() -> void:
	active = false
	await knockback.wait_until_animation_finishes()
	if not is_inside_tree():
		return
	defeated.emit(self, grid.get_grid_position(), drops.roll_items())
	queue_free()
	
