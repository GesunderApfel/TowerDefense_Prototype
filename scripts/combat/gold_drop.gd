extends Node2D

@export var value: int

func _input_event(viewport, event, shape_idx):
	if not event is InputEventMouseButton:
		return
		
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		CurrencySystem.add_coins(value)
		queue_free()
	pass
