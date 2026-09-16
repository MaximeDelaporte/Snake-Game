class_name Wolf
extends Node3D

signal defeated(
	actor: Node3D,
	grid_position:Vector2,
	dropped_item_scenes: Array[PackedScene]
)
const DETECTION_DISTANCE := 6
const CHASE_INTERVAL := 0.15
const NEUTRAL_TEXTURE := preload("res://Assets/Images/Characters/Ennemies/wolf_neutral__placeholder.png")
const ATTACK_TEXTURE := preload("res://Assets/Images/Characters/Ennemies/wolf_attack__placeholder.png")
@export var attack_display_time := 0.2

@onready var sprite: Sprite3D = $Sprite3D
@onready var grid: GridPositionComponent = $GridPositionComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var sensor: PartySensorComponent = $PartySensorComponent
@onready var health: HealthComponent = $HealthComponent
@onready var knockback: KnockbackComponent = $KnockbackComponent
@onready var attack: AttackComponent = $AttackComponent
@onready var drops: DropComponent = $DropComponent

var active := false
var hit_feedback_tween: Tween
func _ready() ->void:
	sprite.texture = NEUTRAL_TEXTURE
	add_to_group("NPCs")
	add_to_group("Enemies")
	add_to_group("Wolves")
	
func configure(
	heroes_party: HeroesParty,
	world_clock: IncrementalTimer,
	grid_occupancy: GridOccupancy
) -> void:
	sensor.configure(heroes_party)
	attack.configure(heroes_party, world_clock)
	movement.configure(grid_occupancy, world_clock)
	knockback.configure(grid_occupancy)
func activate()-> void:
	if active:
		return
	active = true
	behavior_loop()
func behavior_loop()->void:
	while active and is_inside_tree():
		var wait_time := await take_turn()
		if not is_inside_tree():
			return
		await movement.wait_world_seconds(wait_time)
func defeat() -> void:
	active = false
	await knockback.wait_until_animation_finishes()
	if not is_inside_tree():
		return
	defeated.emit(self, grid.get_grid_position(), drops.roll_items())
	queue_free()
func take_turn() -> float:
	var leader := sensor.get_leader()
	if leader == null or not is_inside_tree():
		return 1.0 
	sprite.texture = NEUTRAL_TEXTURE
	var attack_direction := get_direction_toward(
		sensor.get_leader_position()
	)
	if attack.can_attack(
		leader,
		grid.get_grid_position(),
		attack_direction
	):
		await perform_attack(leader, attack_direction)
		return maxf(
			CHASE_INTERVAL,
			attack.get_cooldown_remaining()
		)
	var approach_position := sensor.get_target_position(
		PartySensorComponent.TargetPosition.CLOSEST_SIDE
	)
	if sensor.is_leader_within_distance(DETECTION_DISTANCE):
		await movement.move_steps(
			get_chase_direction(approach_position),
			1
		)
		return CHASE_INTERVAL
	await movement.move_steps(movement.get_random_direction(), 1)
	return randf_range(0.75, 1.25)
func get_chase_direction(leader_position: Vector2) -> Vector2:
	var delta = leader_position - grid.get_grid_position()
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

func get_direction_toward(target_position: Vector2) -> Vector2:
	var delta := target_position - grid.get_grid_position()
	if delta == Vector2.ZERO:
		return Vector2.ZERO
	if absf(delta.x) >= absf(delta.y):
		return Vector2(signf(delta.x), 0)
	return Vector2(0, signf(delta.y))

func receive_hit(amount: int, direction: Vector2) -> bool:
	var was_depleted := health.take_damage(amount)
	show_hit_feedback()
	knockback.apply(direction)
	if was_depleted:
		defeat()
	return was_depleted

func show_hit_feedback() -> void:
	if hit_feedback_tween != null and hit_feedback_tween.is_valid():
		hit_feedback_tween.kill()
	sprite.modulate = Color.RED
	hit_feedback_tween = create_tween()
	hit_feedback_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func perform_attack(target: Hero, attack_direction: Vector2) -> void:
	sprite.texture = ATTACK_TEXTURE
	await movement.wait_world_seconds(attack_display_time)
	if is_instance_valid(target):
		attack.attack(
			target,
			grid.get_grid_position(),
			attack_direction
		)
	if is_inside_tree():
		sprite.texture = NEUTRAL_TEXTURE
	
