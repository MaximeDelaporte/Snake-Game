class_name EnemySpawnDefinition
extends Resource

@export var enemy_scene: PackedScene

@export_range(0,100,1)
var target_alive :=1

@export_range(-1, 10000, 1)
var total_spawn_limit := 1
