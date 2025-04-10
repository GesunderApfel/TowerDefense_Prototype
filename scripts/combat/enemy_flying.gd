extends CharacterBody2D

@onready var state_chart = $StateChart

const FIREBALL = preload("res://scenes/combat/combat_test/fireball.tscn")

@onready var sprite = $Animator/AnimatedSprite2D
@onready var body2d = $CS2D_BodyCollider
@onready var combat_health_bar = $CombatHealthBar


# animations
@onready var animation_tree = $Animator/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback

# physics
@onready var area_scan_radius = $Areas/Area_ScanRadius
@onready var area_attack_range = $Areas/Area_AttackRange

# timers
@onready var timer_attack_interval = $Timers/Attacks/Timer_AttackInterval
var timer_animation_dict = {}
@export var animation_names : Array = ["attacking", "dying", "getting_hit"]

# members
var health
var max_health := 4
var move_speed := 80
@export var attack := 2
var defense := 0

var carriage:Node
var target:Node
var target_focused:Node

var is_looking_left

func _ready():
	animation_tree.active = true
	
	health = max_health
	
	# add all necessary timers
	for animation_name in animation_names:
		var new_timer = Timer.new()
		new_timer.one_shot = true
		new_timer.wait_time = animation_tree.get_animation(animation_name).length
		timer_animation_dict[animation_name] = new_timer
		self.add_child(new_timer)
	
	var state_machine = animation_tree.get("parameters/playback") 
	if state_machine is AnimationNodeStateMachinePlayback:
		animation_state_machine = state_machine
	else:
		push_error("The animation tree does not have a state machine as root node.")
	pass

func _physics_process(_delta):
	if target_focused == null:
		find_target()
	else:
		target = target_focused
	
	look_at_target()
	pass

func find_target():
	var nextTarget:Node
	var nearest_distance:= 10000
	
	for body in area_scan_radius.get_overlapping_bodies():
		if body.is_in_group("carriage") or body.is_in_group("ally"):
			if position.distance_to(body.position) < nearest_distance:
				nearest_distance = position.distance_to(body.position)
				nextTarget = body
	
	
	if nextTarget:
		target = nextTarget
	else:
		target = carriage
	pass

func look_at_target():
	is_looking_left = position.direction_to(target.position).x < 0
	sprite.flip_h = is_looking_left
	pass

func receive_damage(damage):
	health -= max(damage-defense,0)
	combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)

	if health <= 0:
		state_chart.send_event("dying")
	else:
		state_chart.send_event("get_hit")
	pass

# ################
# State Handling
# ################

func _on_move_state_physics_processing(delta):
	if area_attack_range.overlaps_body(target.body2D):
		target_focused = target
		timer_attack_interval.start()
		state_chart.send_event("target_in_range")
		return
	
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	pass

func _on_idle_state_physics_processing(delta):
	if target_focused == null:
		state_chart.send_event("target_not_in_range")
		return
	
	if not area_attack_range.overlaps_body(target_focused.body2D):
		state_chart.send_event("target_not_in_range")
		return
	
	if timer_attack_interval.is_stopped():
		state_chart.send_event("attack_cooldown_finished")
		return
	pass


func _on_attack_state_physics_processing(delta):
	if timer_animation_dict["attacking"].is_stopped():
		state_chart.send_event("attacked")
	pass 

func spawn_projectile():
	if not target_focused:
		return
	
	var fireball = FIREBALL.instantiate()
	self.add_child(fireball)
	fireball.global_position = global_position
	
	var direction : Vector2 = (target_focused.global_position \
	-fireball.global_position + Vector2(0,-65)).normalized()
	fireball.set_direction(direction)
	fireball.set_collision_masks([2,3])
	fireball.set_damage_value(attack)

func _on_dying_state_physics_processing(delta):
	if timer_animation_dict["dying"].is_stopped():
		queue_free()
	pass
	

func _on_get_hit_state_physics_processing(delta):
	if timer_animation_dict["getting_hit"].is_stopped():
		state_chart.send_event("return_to_old_state")
	pass

# ######
# handle transitions
# ######
func _on_move_state_entered():
	animation_state_machine.travel("moving")
	pass

func _on_attack_state_entered():
	timer_animation_dict["attacking"].start()
	timer_attack_interval.start()
	animation_state_machine.travel("attacking")
	pass

func _on_attack_target_state_entered():
	# cooldown time before starting attack
	timer_attack_interval.start()
	pass

func _on_idle_state_entered():
	animation_state_machine.travel("idle")
	pass

func _on_dying_state_entered():
	animation_state_machine.travel("dying")
	timer_animation_dict["dying"].start()
	pass

func _on_get_hit_state_entered():
	animation_state_machine.travel("getting_hit")
	timer_animation_dict["getting_hit"].start()
	pass



