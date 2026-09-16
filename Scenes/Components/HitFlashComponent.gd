class_name HitFlashComponent
extends Node

@export var sprite: Sprite3D
@export var flash_interval := 0.1

var is_flashing := false

func start() -> void:
	if is_flashing: return
	is_flashing = true
	flash_loop()
func stop() -> void:
	is_flashing = false
	if sprite != null:
		sprite.modulate = Color.WHITE
func flash_loop() ->void:
	while is_flashing and is_inside_tree():
		sprite.modulate = Color.RED
		await get_tree().create_timer(flash_interval).timeout
		if not is_inside_tree(): return
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(flash_interval).timeout
