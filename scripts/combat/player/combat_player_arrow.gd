extends Node2D

@onready var sprite = $Sprite2D
@onready var area = $Area
@onready var collision_shape = $Area/CollisionShape


var velocity: Vector2
@export var gravity: float = GlobalConstants.COMBAT_GRAVITY

var damage := 0.0
var is_destroyed := false # prevents hitting multiple objects with one call

# prediction & kill cam
@export var prediction_steps := 30
@export var prediction_step_time := 0.025
var cinema_check_done := false

var debug_node : DebugDrawNode

func _ready():
	debug_node = preload("res://scripts/debug/debug_draw_node.gd").new()
	get_tree().current_scene.add_child(debug_node)
	pass

# ############################
# Movement & Collision #######
# ############################



func set_direction_and_speed(direction: Vector2, speed: float):
	velocity = direction.normalized() * speed
	look_at(global_position + velocity)

	if not cinema_check_done and check_for_killshot():
		CameraManager.focus_on(self)
		cinema_check_done = true
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
	
	# clear focus if cinema effect was activated
	if cinema_check_done:
		CameraManager.clear_focus()
	
	is_destroyed = true
	debug_node.queue_free()
	queue_free()
	pass


# ############################
# Prediction & Kill Cam ######
# ############################

func check_for_killshot() -> bool:
	for enemy in WaveManager.living_enemies:
		#TODO: only if the shot would kill
		if WaveManager.is_last_enemy(enemy):
			return predict_hit(enemy)
	return false

func predict_hit(enemy) -> bool:
	assert(enemy.collider != null, "Enemy has no collider variable")
	
	#TODO: Currently we are predicting if a point is in a shape
	# but this is unprecise, we need the radius (circle) of the arrow
	# and check if it overlaps 
	
	var sim_arrow_pos = global_position
	var sim_arrow_velocity = velocity
	var arrow_radius = collision_shape.shape.radius
	
	var collider : CollisionShape2D = enemy.collider
	var sim_enemy_pos = collider.global_position
	var enemy_velocity = enemy.velocity
	
	for i in prediction_steps:
		# predict arrow
		sim_arrow_velocity.y += gravity * prediction_step_time
		sim_arrow_pos += sim_arrow_velocity * prediction_step_time
		
		# predict enemy
		sim_enemy_pos += enemy_velocity * prediction_step_time
		
		debug_node.add_debug_point(sim_arrow_pos, arrow_radius ,Color.GREEN,3)
		debug_node.add_debug_point(sim_enemy_pos,3,Color.RED,3)
		
		if is_point_in_shape(sim_arrow_pos, arrow_radius, sim_enemy_pos, collider):
			return true
	return false

func is_point_in_shape(point: Vector2, arrow_radius: float, predicted_center: Vector2, collider: CollisionShape2D) -> bool:
	var shape : Shape2D = collider.shape
	if shape is CircleShape2D:
		# show enemy collider movement
		debug_node.add_debug_point(predicted_center,shape.radius, Color.RED, 3)
		var total_radius = shape.radius + arrow_radius 
		return point.distance_squared_to(predicted_center) <= total_radius * total_radius
	elif shape is RectangleShape2D:
		var rect := Rect2(predicted_center, shape.size)
		#TODO: this is probably not working because the size is just added to the center which gives an offset
		var clamped_point := point.clamp(rect.position, rect.position + rect.size)
		return clamped_point.distance_squared_to(point) <= arrow_radius * arrow_radius
	elif shape is CapsuleShape2D:
		# show enemy collider movement
		debug_node.add_debug_capsule(collider, predicted_center, Color.RED, 3)
		var half_height : float = (shape.height * 0.5) - shape.radius
		# capsules global up vector
		var up := collider.global_transform.y.normalized()
		
		var top := predicted_center - up * half_height
		var bottom := predicted_center + up * half_height
		
		var ab := bottom - top
		var ap := point - top
		#var t = clamp(ap.dot(ab.normalized()), 0.0, ab.length())
		#var closest = top + ab.normalized() * t
		#return point.distance_squared_to(closest) <= shape.radius * shape.radius
		var ab_len_sq := ab.length_squared()
		var t : float = clamp(ap.dot(ab) / ab_len_sq, 0.0, 1.0)
		var closest := top + ab * t
		
		var total_radius = shape.radius + arrow_radius
		return point.distance_squared_to(closest) <= total_radius * total_radius
		
	assert(false, "CollisionShape type not handled in code.")
	return false

