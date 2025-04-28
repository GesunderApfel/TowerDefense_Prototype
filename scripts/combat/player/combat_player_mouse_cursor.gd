extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _process(_delta):
	global_position = get_global_mouse_position()
	pass
