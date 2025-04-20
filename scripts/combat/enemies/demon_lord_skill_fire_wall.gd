extends Node2D

@onready var collision_shape_2d = $AnimatedSprite2D/Area2D/CollisionShape2D

var damage = 1
var entered_dict : Array = [] 

func _on_area_2d_body_entered(body):
	if not entered_dict.has(body):
		entered_dict.append(body)
		body.receive_damage(damage)
	pass
