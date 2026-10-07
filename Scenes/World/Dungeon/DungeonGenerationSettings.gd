class_name DungeonGenerationSettings
extends Resource

@export var dungeon_grid_size := Vector2i(6,4)
@export_range(2,30,1)
var entrance_to_exit_transitions := 5
@export var include_boss_before_exit := false
@export_range(1,20,1)
var minimum_main_path_turns :=2
@export_range(1,10,1)
var maximum_straight_run := 2
@export_range(1,10,1)
var minimum_x_lanes := 2
@export_range(1,10,1)
var minimum_y_lanes := 2
@export_range(0,8,1)
var branch_count := 3
@export_range(1,5,1)
var minimum_branch_length := 1
@export_range(1,6,1)
var maximum_branch_length :=3
@export_range(1,100,1)
var maximum_layout_attempts := 30
@export_range(0,10,1)
var branch_danger_bonus := 2
@export_range(0,10,1)
var branch_reward_bonus := 2
@export_range(0,20,1)
var minimum_combat_rooms := 1
@export_range(0,20,1)
var minimum_challenge_rooms := 1
@export_range(0.0,1.0,0.05)
var additional_challenge_chance := 0.35
@export var maximum_room_inner_size := Vector2i(39,47)
@export var room_plot_stride := Vector2i(44, 52)
@export_range(1,12,1)
var minimum_connector_span := 3
@export_range(1,100, 1)
var recommended_party_size :=5

func validate_settings(settings: DungeonGenerationSettings) -> bool:
	if settings == null:
		return false
	var boss_room_count := (
		1 if settings.include_boss_before_exit
		else 0
	)
	var ordinary_main_room_count := (
		settings.entrance_to_exit_transitions -1 - boss_room_count
	)
	return (
		settings.dungeon_grid_size.x >=settings.minimum_x_lanes
		and settings.dungeon_grid_size.y >=settings.minimum_y_lanes
		and settings.entrance_to_exit_transitions >= mini(settings.minimum_x_lanes, settings.minimum_y_lanes)
		and settings.minimum_main_path_turns >= 1
		and settings.minimum_main_path_turns <= settings.entrance_to_exit_transitions
		and settings.maximum_straight_run >= 1
		and settings.minimum_branch_length >= 1
		and settings.maximum_branch_length >= minimum_branch_length
		and settings.maximum_layout_attempts > 0
		and settings.branch_count <= ordinary_main_room_count
		and settings.room_plot_stride.x >= (
			settings.maximum_room_inner_size.x + settings.minimum_connector_span
		)
		and settings.room_plot_stride.y >= (
			settings.maximum_room_inner_size.y + settings.minimum_connector_span
		)
		and (
			settings.dungeon_grid_size.x * settings.dungeon_grid_size.y >= 
			settings.entrance_to_exit_transitions 
			+ 1 
			+ settings.branch_count * settings.minimum_branch_length
		)
		and (
			ordinary_main_room_count > settings.minimum_combat_rooms + settings.minimum_challenge_rooms
		)
	)
	
