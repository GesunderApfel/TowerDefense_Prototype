extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area

var velocity: Vector2
@export var gravity: float = 800.0

var damage = 0
var is_destroyed = false # prevents hitting multiple objects with one call

func set_velocity(direction: Vector2, speed: float):
	velocity = direction.normalized() * speed
	look_at(global_position + velocity)
	pass

func set_collision_masks(collision_mask_layer_numbers: Array):
	for mask in collision_mask_layer_numbers:
		area.set_collision_mask_value(mask,true)
	pass

func set_damage_value(value):
	damage = value
	pass

func _process(delta):
	if is_destroyed:
		return
	
	velocity.y += gravity * delta
	position += velocity * delta
	
	look_at(global_position + velocity)
	pass


func _on_area_body_entered(body):
	if is_destroyed:
		return
	
	body.receive_damage(damage)
	
	is_destroyed = true
	queue_free()
	pass
