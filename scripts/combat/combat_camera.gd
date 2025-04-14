extends Camera2D

@export var shake_strength: float = 5.0
@export var shake_duration: float = 0.5

var shake_timer := 0.0

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength
	else:
		offset = Vector2.ZERO
	pass

func start_shake():
	shake_timer = shake_duration
	pass
