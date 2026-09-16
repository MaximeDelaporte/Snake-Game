class_name HazardSpawnDefinition 
extends Resource

enum OccupancyPolicy {
	ENTERABLE,
	BLOCKING,
}
@export var hazard_scene: PackedScene
@export_range(0,100,1)
var initial_count :=1

@export_range(0,20,1)
var minimum_start_distance := 3

@export var occupancy_policy :=  OccupancyPolicy.ENTERABLE
