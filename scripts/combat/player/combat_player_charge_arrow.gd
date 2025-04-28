extends Node2D

@export var max_radius = 30.0
@export var color = Color(1, 1, 1, 0.5)
@export var pulse_speed = 6.0
@export var pulse_strength = 0.2

var charge_percent = 0.0 # 0 to 1
var pulse_timer = 0.0

func _process(delta):
	# pulse at full charge
	if charge_percent >= 1.0:
		pulse_timer += delta * pulse_speed
	else:
		pulse_timer = 0.0
	
	queue_redraw()
	pass

func set_charge(value: float):
	charge_percent = clamp(value, 0.0, 1.0)
	queue_redraw()
	pass
	
func _draw():
	if charge_percent <= 0.0:
		return
		
	var pulse_scale = 1.0
	if charge_percent >= 1.0:
		pulse_scale = 1.0 + floor(sin(pulse_timer * TAU)* 2.0 / 10.0) * pulse_strength
	
	var radius = round(charge_percent * max_radius * pulse_scale)
	draw_circle(Vector2.ZERO, radius, color)
