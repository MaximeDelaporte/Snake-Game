class_name HeroDefinition
extends Resource

@export var type_name := ''
@export var texture: Texture2D
@export var attack_shape: Array[Vector2] = [Vector2(0, 1)]
@export_range(0.0, 60.0, 0.05) var attack_cooldown := 0.5
