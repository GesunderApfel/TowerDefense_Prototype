extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area

var velocity: Vector2
@export var gravity := GlobalConstants.COMBAT_GRAVITY
@export var use_gravity := false
@export var damage := 0.0
@export var speed := 400.0

var is_destroyed := false # prevents hitting multiple objects

func _ready():
	gravity = gravity if use_gravity else 0.0
	pass

# ############################
# Movement & Collision #######
# ############################

func set_direction(direction: Vector2):
	velocity = direction.normalized() * speed
	look_at(global_position + velocity)
	pass

func set_direction_and_speed(direction: Vector2, speed: float):
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

func _physics_process(delta):
	if is_destroyed:
		return
	# move
	velocity.y += gravity * delta
	position += velocity * delta
	# rotate
	look_at(global_position + velocity)
	pass


func _on_area_body_entered(body):
	if is_destroyed:
		return
	
	if body.has_method("receive_damage"):
		body.receive_damage(damage)
	
	is_destroyed = true
	queue_free()
	pass
