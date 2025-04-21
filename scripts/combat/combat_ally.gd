extends CharacterBody2D

enum CombatMovementType {
	GROUNDED, 
	FLYING,
}

enum AllyState {
	DEFEND_CARRIAGE,
	ATTACK_TARGET,
	DYING,
}

enum AnimationTreeState {
	IDLE,
	WALKING,
	ATTACKING,
	DYING
}


var current_state := AllyState.DEFEND_CARRIAGE

var body2D : Node = self
var carriage : Node
var target : Node

@export var carriage_defense_radius := 200.0

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
const animate_state_idle = "idle"
const animate_state_walk = "walk"
const animate_state_die = "die"
const animate_state_attack = "attack"
const animate_state_getHit = "get_hit"


# Physics
@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_attack_radius = $Areas/Area_AttackRadius

# Timers
var timer_animation_dict : Dictionary = {}
@onready var timer_wait_after_melee_attack = $Timers/timer_wait_after_melee_attack
@onready var timer_transition_idle_walk = $Timers/timer_transition_idle_walk


var is_looking_left : bool = false

func _ready():
	health = max_health
	
	animation_tree.active = true
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,animate_state_idle)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,animate_state_walk)
	
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,animate_state_die)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,animate_state_getHit)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,animate_state_attack)
		
		
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
	pass

func _process(_delta):
	look_at_target()

func _physics_process(_delta):
	#print(current_state)
	match current_state:
		AllyState.DEFEND_CARRIAGE:
			state_defend_carriage()
		AllyState.ATTACK_TARGET:
			state_attack_target()
		AllyState.DYING:
			state_dying()
	pass

func look_at_target():
	if(target == null):
		return

	is_looking_left = position.direction_to(target.position).x < 0
	sprite.flip_h = is_looking_left
	pass


func state_defend_carriage():
	for body in area_attack_radius.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			target = body
			current_state = AllyState.ATTACK_TARGET
			return
			
	var carriage_direction : Vector2 = \
		position.direction_to(carriage.position)
		
	var is_carriage_left = carriage_direction.x < 0
	
	if position.distance_to(carriage.position) < carriage_defense_radius:
		animation_tree.current_state = \
			AnimationTreeState.keys()[AnimationTreeState.IDLE]
		if is_carriage_left == is_looking_left:
			is_looking_left = not is_looking_left # turn player in next frame
	else:
		is_looking_left = is_carriage_left
		animation_tree.current_state = \
			AnimationTreeState.keys()[AnimationTreeState.WALKING]
		velocity = move_speed * carriage_direction
		move_and_slide()
	pass

func state_attack_target():
	# if attacked, wait half the time to make next decision
	if timer_animation_dict[AnimationTreeState.WALKING].is_stopped():
		animation_tree.current_state = \
			AnimationTreeState.keys()[AnimationTreeState.IDLE]
			
	if not timer_wait_after_melee_attack.is_stopped() \
		and timer_wait_after_melee_attack.time_left > \
			(timer_wait_after_melee_attack.wait_time / 2):
				return
				
	var enemy : Node
	var nearest_distance = 10000
	for body in area_attack_radius.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			if nearest_distance > body.position.distance_to(position):
				nearest_distance = body.position.distance_to(position)
				enemy = body
	
	# if no enemies are in attack radius -> defend
	if enemy == null:
		current_state = AllyState.DEFEND_CARRIAGE
		return
	
	# check if enemy is in hit range
	var area = attack_area_melee_l if is_looking_left else attack_area_melee_r
	if area.overlaps_body(enemy):
			if timer_wait_after_melee_attack.is_stopped():
				timer_wait_after_melee_attack.start()
				enemy.receive_damage(attack)
				animation_tree.current_state = \
					AnimationTreeState.keys()[AnimationTreeState.ATTACKING]
	else:
		animation_tree.current_state = \
			AnimationTreeState.keys()[AnimationTreeState.WALKING]
		
		timer_animation_dict[AnimationTreeState.WALKING].start()
		var direction_to_enemy = position.direction_to(enemy.position)
		velocity = direction_to_enemy * move_speed
		is_looking_left = false if direction_to_enemy.x > 0 else true
		move_and_slide()
	#	walk to enemy
		
	pass
	
var already_started_dying = false
func state_dying():
	if timer_animation_dict[AnimationTreeState.DYING].is_stopped():
		if already_started_dying:
			queue_free()
		else:
			timer_animation_dict[AnimationTreeState.DYING].start()
		pass
	queue_free()
	pass
	



@onready var combat_health_bar = $CombatHealthBar

func receive_damage(damage):
	health -= max(damage-defense,0)
	combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
	
	if health <= 0:
		current_state= AllyState.DYING
	pass

# ###############################
# Handling State Machine States #
# ###############################

func _on_wait_at_carriage_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_idle)
	pass

func _on_return_to_carriage_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_walk)
	pass

func _on_move_to_target_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_walk)
	pass

func _on_idle_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_idle)
	pass

func _on_attack_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_attack)
	timer_animation_dict[animate_state_attack].start()
	pass

func _on_get_hit_state_physics_processing(_delta):
	animation_state_machine.travel(animate_state_getHit)
	timer_animation_dict[animate_state_getHit].start()
	pass

func _on_die_state_processing(_delta):
	animation_state_machine.travel(animate_state_die)
	timer_animation_dict[animate_state_die].start()
	pass

# ###############################
# Handling State Machine Transitions #
# ###############################

func _on_wait_at_carriage_state_entered():
	
	pass # Replace with function body.

func _on_return_to_carriage_state_entered():
	pass # Replace with function body.

func _on_move_to_target_state_entered():
	pass # Replace with function body.

func _on_idle_state_entered():
	pass # Replace with function body.

func _on_attack_state_entered():
	pass # Replace with function body.

func _on_get_hit_state_entered():
	pass # Replace with function body.

func _on_die_state_entered():
	pass # Replace with function body.





