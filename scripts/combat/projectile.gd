extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area

var direction : Vector2
@export var speed : float = 100

var damage = 0

var is_destroyed = false # prevents hitting multiple objects with one call

func set_direction(value : Vector2):
	direction = value
	look_at((global_position + value))

func set_collision_masks(collision_mask_layer_numbers : Array):
	for mask in collision_mask_layer_numbers:
		area.set_collision_mask_value(mask,true)

func set_damage_value(value):
	damage = value

func _process(delta):
	position += delta * direction * speed



func _on_area_body_entered(body):
	if is_destroyed:
		return
	
	body.receive_damage(damage)
	is_destroyed = true
	queue_free()
	pass # Replace with function body.
