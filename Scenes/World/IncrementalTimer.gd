class_name IncrementalTimer
extends Node

signal advanced(scaled_delta: float)

@export_range(0.0, 10.0, 0.05)
var speed_multiplier := 1.0:
	set(value):
		speed_multiplier = maxf(0.0, value)
var elapsed_time := 0.0

func _process(delta: float) -> void:
	var scaled_delta := delta * speed_multiplier
	elapsed_time += scaled_delta
	advanced.emit(scaled_delta)
func wait_seconds(duration: float) -> void:
	var deadline := elapsed_time + maxf(0.0, duration)
	while elapsed_time < deadline and is_inside_tree():
		await advanced
func reset() -> void:
	elapsed_time = 0.0
