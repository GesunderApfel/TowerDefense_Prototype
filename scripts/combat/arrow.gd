extends Node2D

var direction : Vector2
@export var speed : float = 100

func set_direction(value):
	self.direction = value

func _process(delta):
	position += delta * direction * speed


func _on_area_body_entered(body):
	if body.is_in_group("enemy"):
		body.receive_damage(2)
		queue_free()
	pass # Replace with function body.
