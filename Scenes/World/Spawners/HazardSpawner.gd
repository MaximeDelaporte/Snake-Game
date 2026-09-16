class_name HazardSpawner
extends Node3D

const BODY_SEGMENT_SIZE := 1

@export var walls: Walls
@export var heroes_party: HeroesParty
@export var world_clock: IncrementalTimer
@export var grid_occupancy: GridOccupancy
@export var spawn_definitions: Array[HazardSpawnDefinition] = []

@export_range(1, 4096,1)
var maximum_placement_attempts := 256

@onready var hazards: Node3D = $Hazards
@onready var enterable_hazards: Node3D = $Hazards/Enterable
@onready var blocking_hazards: Node3D = $Hazards/Blocking
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("spawn_initial_hazards")
func spawn_initial_hazards() -> void:
	if walls == null or grid_occupancy == null:
		push_error(
			"HazardSpawner requires"
		)
		return
	for definition in spawn_definitions:
		if definition == null:
			continue
		spawn_definition(definition)
func spawn_definition(definition: HazardSpawnDefinition) -> int:
	if definition == null or definition.hazard_scene == null:
		return 0
	var created := 0
	for _index in range(definition.initial_count):
		if spawn_hazard(definition) == null:
			push_warning("Stopped placing hazards after %d instances" % created)
			break
		created +=1
	return created
func spawn_hazard(definition: HazardSpawnDefinition)-> Node3D:
	if definition == null or definition.hazard_scene == null:
		return null
	var instance := definition.hazard_scene.instantiate()
	var hazard := instance as Node3D
	if hazard == null:
		push_error("A hazard scene must have a Node3D root")
		instance.free()
		return null
	var target_container := get_container_for_definition(definition)
	target_container.add_child(hazard)
	var grid := hazard.get_node_or_null("GridPositionComponent") as GridPositionComponent
	var footprint := hazard.get_node_or_null("GridFootprintComponent") as GridFootprintComponent
	if (
		grid == null
		or footprint == null
		or footprint.grid_position != grid
	):
		push_error("Hazard requires wired grid-position and footprint components")
		hazard.queue_free()
		return null
	var origin_value := find_spawn_origin(definition, hazard, footprint) as Vector2
	if origin_value == null: 
		push_warning("No valid origin was found for the hazard footprint")
		hazard.queue_free()
		return null
	var origin: Vector2 = origin_value
	grid.set_grid_position(origin)
	if hazard.has_method("configure_hazard"):
		hazard.call(
			"configure_hazard",
			heroes_party,
			world_clock,
			grid_occupancy
		)
		if hazard.has_method("activate"):
			hazard.call("activate")
	return hazard
func get_container_for_definition(definition: HazardSpawnDefinition)-> Node3D:
	if (definition.occupancy_policy == HazardSpawnDefinition.OccupancyPolicy.BLOCKING):
		return blocking_hazards
	return enterable_hazards
func find_spawn_origin(definition:HazardSpawnDefinition, hazard: Node3D, footprint: GridFootprintComponent)-> Variant:
	var minimum_x := ceili(walls.top_left_corner.x) + BODY_SEGMENT_SIZE
	var maximum_x := floori(walls.bottom_right_corner.x) - BODY_SEGMENT_SIZE
	var minimum_y := ceili(walls.top_left_corner.y) + BODY_SEGMENT_SIZE
	var maximum_y := floori(walls.bottom_right_corner.y) -BODY_SEGMENT_SIZE
	if minimum_x> maximum_x or minimum_y > maximum_y:
		push_error("The wall bounds contain no spawnable cells")
		return null
	for _attempt in range(maximum_placement_attempts):
		var candidate := Vector2(randi_range(minimum_x, maximum_x),randi_range(minimum_y, maximum_y))
		if is_origin_valid(candidate, definition,hazard,footprint):
			return candidate
	return null
func is_origin_valid(
	candidate: Vector2,
	definition: HazardSpawnDefinition,
	hazard: Node3D,
	footprint: GridFootprintComponent
)-> bool:
	var cells := footprint.get_cells_at(candidate)
	if cells.is_empty():
		return false;
	var has_leader := (
		heroes_party != null
		and heroes_party.get_leader() != null
	)
	var start := Vector2.ZERO
	if has_leader:
		start= heroes_party.get_leader_grid_position()
	for cell in cells:
		if not grid_occupancy.is_grid_position_free(cell, hazard):
			return false
		if has_leader:
			var distance_from_start := (absf(cell.x -start.x)+ absf(cell.y - start.y))
			if (distance_from_start < definition.minimum_start_distance):
				return false
	return true
func get_hazard_at_position(target_position: Vector2, ignored_hazard: Node3D = null)-> Node3D:
	for container in [blocking_hazards, enterable_hazards]:
		for child in container.get_children():
			var hazard := child as Node3D
			if (
				hazard == null
				or hazard == ignored_hazard
				or hazard.is_queued_for_deletion()
			):
				continue
			var footprint:= hazard.get_node_or_null("GridFootprintComponent") as GridFootprintComponent
			if (
				footprint != null
				and footprint.contains(target_position)
			):
				return hazard
	return null
