extends CharacterBody2D

@onready var state_chart = $StateChart

var body2D : Node = self
@onready var sprite = $Animator/AnimatedSprite2D
var is_looking_left = false

var carriage # will be set by the spawner
var target:Node
var target_focused:Node

@onready var combat_health_bar = $CombatHealthBar

# Flyweight Pattern? Allows for composition instead of inheritance...
var health
var max_health = 25
var move_speed = 120
@export var attack_damage = 1
var defense = 0
var attack_frequence = 2.5 #in seconds

# Modes & Skills
const SKILL_FIREWALL = preload("res://scenes/combat/combat_test/demon_lord_skill_fire_wall.tscn")

# Physics & Colliders
@onready var collision_shape_2d = $CollisionShape2D
@onready var areas_facing_right = $Areas/Areas_FacingRight
@onready var areas_facing_left = $Areas/Areas_FacingLeft

@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_scan_radius = $Areas/Area_ScanRadius

# Animation
@onready var animation_tree = $Animator/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback
const anim_state_idle = "idle"
const anim_state_walk = "walk"
const anim_state_attack = "attack"
const anim_state_getHit = "get_hit"
const anim_state_die = "die"
const anim_state_skillFireWall = "skill_fire_wall"

# Timers
var timer_animation_dict : Dictionary = {}
@onready var timer_attack : Timer = $Timers/AttackTimer
@onready var timer_skill_firewall = $Timers/SkillFirewallTimer

func _ready():
	animation_tree.active = true
	health = max_health
	
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_idle)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_walk)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_attack)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_skillFireWall)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_getHit)
	
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_die)
		
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
	
	CombatDebug.bind_debug_method(debug_activate_fire_wall, "Demon Lord: Firewall")
	pass

func _process(_delta):
	look_at_target()

func find_next_target():
	var nextTarget : Node
	var nearest_distance := 10000.0
	
	# sets nearest player ally as next target
	for body in area_scan_radius.get_overlapping_bodies():
		if body.is_in_group("ally"):
			if nearest_distance > position.distance_to(body.position):
				nearest_distance = position.distance_to(body.position)
				nextTarget = body

	# if no player ally is found, carriage is next target
	if nextTarget == null:
		nextTarget  = carriage
	
	target = nextTarget
	pass

func look_at_target():
	if(target == null):
		return
	# > 0 because it is already flipped
	is_looking_left = position.direction_to(target.position).x > 0
	sprite.flip_h = is_looking_left

func _physics_process(_delta):
	if target == null:
		return

	# "flip" scan & attack areas
	# todo: one area which x position will be inverted
	if is_looking_left:
		areas_facing_left.show()
		areas_facing_right.hide()
	else:
		areas_facing_right.show()
		areas_facing_left.hide()
	pass

func receive_damage(damage):
	# receive damage
	health -= max(damage-defense,0)
	combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
	
	if health <= 0:
		state_chart.send_event("sce_die")
	else:
		# if not is_berserk and timer_animation_dict["attack"].is_stopped():
		state_chart.send_event("sce_get_hit")
	pass

# ############################
# DEBUG ######################
# ############################

func debug_activate_fire_wall():
	state_chart.send_event("sce_skill_fire_wall")
	pass

# #############################
# Called by Animations ########
# #############################

func apply_attack_damage():
	if target != null:
		target.receive_damage(attack_damage)
	pass


# ##############################
# Handling States  #############
# ##############################


func _on_idle_state_physics_processing(_delta):
	# enemy: wait and decide what to do next
	if not target_focused:
		state_chart.send_event("sce_move_to_target")
		return
	
	if not timer_attack.is_stopped():
		return
	
	timer_attack.start()
	
	# throw a dice for skill usage
	var is_using_skill : bool = use_skill()
	
	if is_using_skill:
		state_chart.send_event("sce_skill_fire_wall")
		pass
	else: # use normal attack
		# regulate attack inverval
		state_chart.send_event("sce_attack")
	pass

func use_skill():
	var is_using_skill : bool
	# dice throw timer regulates the cooldown time for the AI
	# to decide on any skill
	if timer_skill_firewall.is_stopped():
		# magic number, feels good for now
		# todo: implementing a skill pool
		is_using_skill = randi_range(0,100) > 70
	return is_using_skill 

func _on_move_to_target_state_physics_processing(_delta):
	# should be set by next frame via _process()
	find_next_target()
	
	if target == null:
		return;
	
	# move to target
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	
	if attack_area_melee_r.overlaps_body(target.body2D) \
	or attack_area_melee_l.overlaps_body(target.body2D):
		target_focused = target
		state_chart.send_event("sce_attack")
	pass



func _on_attack_state_physics_processing(_delta):
	if not timer_animation_dict[anim_state_attack].is_stopped():
		return
	
	state_chart.send_event("sce_idle")
	pass



func _on_skill_fire_wall_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_skillFireWall].is_stopped():
		state_chart.send_event("sce_idle")
	pass

func _on_get_hit_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_getHit].is_stopped():
		state_chart.send_event("sce_old_state")
	pass

func _on_die_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_die].is_stopped():
		queue_free()
	pass


# ##############################
# Handling State Transitions ###
# ##############################

func _on_idle_state_entered():
	animation_state_machine.travel(anim_state_idle)
	pass

func _on_move_to_target_state_entered():
	animation_state_machine.travel(anim_state_walk)
	pass

func _on_attack_state_entered():
	timer_animation_dict[anim_state_attack].start()
	animation_state_machine.travel(anim_state_attack)
	pass


func _on_get_hit_state_entered():
	timer_animation_dict[anim_state_getHit].start()
	animation_state_machine.travel(anim_state_getHit)
	pass

func _on_die_state_entered():
	timer_animation_dict[anim_state_die].start()
	animation_state_machine.travel(anim_state_die)
	pass

func _on_skill_fire_wall_state_entered():
	timer_animation_dict[anim_state_skillFireWall].start()
	animation_state_machine.travel(anim_state_skillFireWall)
	pass
