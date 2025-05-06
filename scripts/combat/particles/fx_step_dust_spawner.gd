extends Node2D

const FX_STEP_DUST = preload("res://scenes/combat/combat_test/vfx/fx_step_dust.tscn")
@onready var step_dust_position = $StepDustPosition

func spawn_dust():
	var dust = FX_STEP_DUST.instantiate()
	dust.global_position = step_dust_position.global_position
	get_tree().current_scene.add_child(dust)
	pass
