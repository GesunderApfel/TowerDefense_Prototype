extends StaticBody2D

@export var damage_receiver:Node = null

func _ready():
	if damage_receiver == null:
		push_error("No damage receiver assigned.")

func receive_damage(value):
	damage_receiver.receive_damage(value)
