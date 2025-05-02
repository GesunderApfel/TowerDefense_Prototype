extends CharacterBody2D

@onready var state_chart = $StateChart

var body2D : Node = self
var carriage : Node
var target : Node

@export var carriage_defense_radius := 200.0

@onready var combat_health_bar = $CombatHealthBar

# members
var health : int
var max_health : int = 18
var attack : int = 4
var defense: int = 0
var move_speed : float = 200


# animation
@onready var sprite = $Visuals/AnimatedSprite2D
@onready var animation_tree = $Visuals/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback
const anim_state_idle = "idle"
const anim_state_walk = "walk"
const anim_state_die = "die"
const anim_state_attack = "attack"
const anim_state_getHit = "get_hit"


# Physics
@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_attack_radius = $Areas/Area_ScanRadius

# Timers
var timer_animation_dict : Dictionary = {}
@onready var timer_attack = $Timers/timer_attack

var is_looking_left : bool = false

func _ready():
	health = max_health
	look_away_from_carriage()
	
	
	animation_tree.active = true
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_idle)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_walk)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_die)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_getHit)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_attack)
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
	pass

func _process(_delta):
	look_at_target()

func look_at_target():
	if target == null:
		return
	
	is_looking_left = position.direction_to(target.position).x < 0
	sprite.flip_h = is_looking_left
	pass

func look_away_from_carriage():
	is_looking_left = position.direction_to(carriage.position).x > 0
	sprite.flip_h = is_looking_left
	pass


## could return list of enemies
func find_enemy():
	var enemy : Node
	var nearest_distance = 10000
	for body in area_attack_radius.get_overlapping_bodies():
		if body.is_in_group("enemy") and not body.is_in_group("flying"):
			if nearest_distance > body.position.distance_to(position):
				nearest_distance = body.position.distance_to(position)
				enemy = body
	
	return enemy

func is_target_in_hit_range():
	if target == null:
		return
	
	var area = attack_area_melee_l if is_looking_left else attack_area_melee_r
	if area.overlaps_body(target):
		return true
	return false

func receive_damage(damage):
	health -= max(damage-defense,0)
	combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
	
	if health <= 0:
		state_chart.send_event("sce_die")
	else:
		state_chart.send_event("sce_get_hit")
	pass

func apply_attack_damage():
	if target != null:
		target.receive_damage(attack)
	pass

# ###############################
# Handling State Machine States #
# ###############################


# #########
# Defend Carriage
# #########

func _on_wait_at_carriage_state_physics_processing(_delta):
	var enemy = find_enemy()
	if enemy:
		state_chart.send_event("sce_start_combat")
		return
	pass

func _on_return_to_carriage_state_physics_processing(_delta):
	target = find_enemy()
	if target:
		state_chart.send_event("sce_start_combat")
		return
	
	target = carriage
	var carriage_direction : Vector2 = \
		position.direction_to(target.position)
	
	if position.distance_to(target.position) < carriage_defense_radius:
		state_chart.send_event("sce_wait")
	else:
		velocity = move_speed * carriage_direction
		move_and_slide()
	pass

# #########
# In Combat
# #########


func _on_move_to_target_state_physics_processing(_delta):
	target = find_enemy()

	if not target:
		state_chart.send_event("sce_start_defense")
		return
	
	if is_target_in_hit_range():
		state_chart.send_event("sce_idle")
		return
	
	var direction_to_enemy = position.direction_to(target.position)
	velocity = direction_to_enemy * move_speed
	move_and_slide()
	pass

func _on_idle_state_physics_processing(_delta):
	target = find_enemy()
	var is_enemy_in_hit_range = is_target_in_hit_range()
	if is_enemy_in_hit_range:
		if timer_attack.is_stopped():
			timer_attack.start()
			state_chart.send_event("sce_attack")
	else:
		state_chart.send_event("sce_move")
	pass

func _on_attack_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_attack].is_stopped():
		state_chart.send_event("sce_idle")
	pass

func _on_get_hit_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_getHit].is_stopped():
		state_chart.send_event("sce_old_state")
	pass

func _on_die_state_processing(_delta):
	if timer_animation_dict[anim_state_die].is_stopped():
		queue_free()
	pass

# ###############################
# Handling State Machine Transitions #
# ###############################

func _on_wait_at_carriage_state_entered():
	animation_state_machine.travel(anim_state_idle)
	# reset target
	target = null
	look_away_from_carriage()
	pass # Replace with function body.

func _on_return_to_carriage_state_entered():
	animation_state_machine.travel(anim_state_walk)
	pass # Replace with function body.

func _on_move_to_target_state_entered():
	animation_state_machine.travel(anim_state_walk)
	pass # Replace with function body.

func _on_idle_state_entered():
	animation_state_machine.travel(anim_state_idle)
	pass # Replace with function body.

func _on_attack_state_entered():
	animation_state_machine.travel(anim_state_attack)
	timer_animation_dict[anim_state_attack].start()
	pass # Replace with function body.

func _on_get_hit_state_entered():
	animation_state_machine.travel(anim_state_getHit)
	timer_animation_dict[anim_state_getHit].start()
	pass # Replace with function body.

func _on_die_state_entered():
	animation_state_machine.travel(anim_state_die)
	timer_animation_dict[anim_state_die].start()
	pass # Replace with function body.





