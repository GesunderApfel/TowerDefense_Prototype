extends Node

@export var normal_zoom := Vector2(1, 1)
@export var cinema_zoom := Vector2(1.4, 1.4)
@export var zoom_speed := 6.0

var target_node: Node2D = null
var active: bool = false
var camera: Camera2D

var original_position : Vector2

func _ready():
	camera = get_viewport().get_camera_2d()
	original_position = camera.global_position
	pass

func focus_on(node: Node2D):
	if active:
		return
	
	target_node = node
	active = true
	Engine.time_scale = 0.15
	camera.zoom = normal_zoom # resetting any external settings
	pass

func clear_focus():
	target_node = null
	active = false
	Engine.time_scale = 1.0
	camera.zoom = normal_zoom
	
	camera.global_position = original_position
	pass

func _process(delta):
	if not active or target_node == null or not is_instance_valid(target_node):
		return
	
	# 5.0 is magic number
	camera.global_position = camera.global_position.lerp(target_node.global_position, delta * 15.0)
	#camera.zoom = camera.zoom.lerp(cinema_zoom, delta * zoom_speed)
	pass
