class_name EnemySpawner
extends Node3D

const BODY_SEGMENT_SIZE := 1

@export var walls: Walls
@export var heroes_party: HeroesParty
@export var world_clock: IncrementalTimer
@export var grid_occupancy: GridOccupancy
@export var item_spawner: ItemSpawner
@export var respawn_delay := 2.0
@export var  spawn_definitions: Array[EnemySpawnDefinition] = []

@onready var enemies : Node3D = $Enemies

var spawned_totals: Dictionary = {}
var actor_definitions: Dictionary = {}

func _ready() -> void:
	for definition in spawn_definitions:
		if definition == null:
			continue
		spawned_totals[definition] = 0
		spawn_until_capacity(definition)
func spawn_until_capacity(definition: EnemySpawnDefinition, excluded_positions: Array = []) -> void:
	while(
		count_alive(definition) < definition.target_alive
		and can_spawn(definition)
	):
		if spawn_enemy(definition, excluded_positions) == null:
			return
func count_alive(definition: EnemySpawnDefinition) -> int:
	var results :=0
	for actor_definition in actor_definitions.values():
		if actor_definition == definition:
			results += 1
	return results
func can_spawn(definition: EnemySpawnDefinition) -> bool:
	return (
		definition.total_spawn_limit < 0
		or int(spawned_totals.get(definition, 0)) < definition.total_spawn_limit
	)
func spawn_enemy(
	definition: EnemySpawnDefinition,
	excluded_positions: Array = []
) -> Node3D:
	if definition == null or definition.enemy_scene == null:
		return null
	if not can_spawn(definition): return null
	var actor := definition.enemy_scene.instantiate()
	if actor == null :
		push_error("The supplied enemy scene must have a Node3D root")
		return null
	enemies.add_child(actor)
	var grid := actor.get_node_or_null(
		"GridPositionComponent"
	) as GridPositionComponent
	if grid == null or not actor.has_method("configure"):
		push_error("Enemy scene is missing its composition contract")
		actor.queue_free()
		return null
	actor.call(
		"configure",
		heroes_party,
		world_clock,
		grid_occupancy
	)
	grid.set_grid_position(generate_position(excluded_positions, actor))
	if actor.has_signal("defeated"):
		actor.connect("defeated", _on_enemy_defeated)
	actor_definitions[actor] = definition
	spawned_totals[definition] = int(spawned_totals.get(definition, 0) + 1)
	if actor.has_method("activate"):
		actor.call("activate")
	return actor
func generate_position(excluded_positions: Array = [],
ignored_actor: Node3D = null) -> Vector2:
	for _attempt in range(128):
		var x_position := randi_range(
			int(walls.top_left_corner.x + BODY_SEGMENT_SIZE),
			int(walls.bottom_right_corner.x - BODY_SEGMENT_SIZE)
		)
		var y_position := randi_range(
			int(walls.top_left_corner.y + BODY_SEGMENT_SIZE),
			int(walls.bottom_right_corner.y - BODY_SEGMENT_SIZE)
		)
		var candidate := Vector2(x_position, y_position)
		if grid_occupancy.is_grid_position_free(
			candidate,ignored_actor,excluded_positions
		): return candidate
	push_error("No free enemy spawn position was found")
	return Vector2.ZERO
func get_enemy_at_position(
	target_position: Vector2,
	ignored_actor: Node3D = null
) -> Node3D:
	for child in enemies.get_children():
		var actor := child as Node3D
		if actor == null or actor == ignored_actor:
			continue
		var grid := actor.get_node_or_null(
			"GridPositionComponent"
		) as GridPositionComponent
		if grid != null and grid.get_grid_position() == target_position:
			return actor
	return null
	
func _on_enemy_defeated(
	actor: Node3D,
	grid_position: Vector2,
	dropped_item_scenes: Array[PackedScene]
) -> void:
	var definition := actor_definitions.get(actor) as EnemySpawnDefinition
	actor_definitions.erase(actor)
	for item_scene in dropped_item_scenes:
		if item_spawner != null:
			if item_spawner != null:
				item_spawner.spawn_item(item_scene, grid_position)
	if definition != null:
		queue_delayed_respawn(definition, [grid_position])
func queue_delayed_respawn(
	definition: EnemySpawnDefinition,
	excluded_positions: Array = []
) -> void:
		await world_clock.wait_seconds(respawn_delay)
		if not is_inside_tree():
			return
		if count_alive(definition) < definition.target_alive:
			spawn_enemy(definition, excluded_positions)
