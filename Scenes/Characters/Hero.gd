class_name Hero

extends Node3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var health: HealthComponent  = $HealthComponent
@onready var hit_flash: HitFlashComponent = $HitFlashComponent
@onready var attack: AttackComponent = $AttackComponent
var definition: HeroDefinition
var type := ""

func apply_definition(new_definition: HeroDefinition) ->void:
	if new_definition == null:
		push_error("Cannot apply a null HeroDefinition")
		return
	definition = new_definition
	type = definition.type_name
	sprite.texture = definition.texture
	attack.attack_shape = definition.attack_shape.duplicate()
	attack.cooldown_seconds = definition.attack_cooldown

func configure_attack(party_clock: IncrementalTimer) -> void:
	attack.configure(null, party_clock)

func on_hit() -> void:
	hit_flash.start()
func on_invulnerability_stop()-> void :
	hit_flash.stop()
