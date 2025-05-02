extends CharacterBody2D

@onready var state_chart = $StateChart

var body2D : Node = self
@onready var collider = $Collider

@onready var sprite = $Visuals/AnimatedSprite2D
var is_looking_left = false

var carriage
var target:Node
var target_focused:Node

@onready var combat_health_bar = $CombatHealthBar

# Flyweight Pattern? Allows for composition instead of inheritance...
var health
var max_health = 10
var move_speed = 120
@export var attack_damage = 1
var defense = 0
var attack_frequence = 2.5 #in seconds

# Modes & Skills
var is_berserk: bool = false


# Physics & Colliders
@onready var areas_facing_right = $Areas/Areas_FacingRight
@onready var areas_facing_left = $Areas/Areas_FacingLeft

@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_scan_radius = $Areas/Area_ScanRadius

# Animation
@onready var animation_tree = $Visuals/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback
const anim_state_idle = "idle"
const anim_state_walk = "walk"
const anim_state_attack = "attack"
const anim_state_getHit = "get_hit"
const anim_state_skillBerserk = "skill_berserk"

# Timers
var timer_animation_dict : Dictionary = {}
@onready var timer_attack : Timer = $Timers/Attacks/AttackTimer
@onready var timer_berserk_duration : Timer = $Timers/Attacks/Skill_Berserk_Duration
@onready var timer_berserk_attack : Timer = $Timers/Attacks/Skill_Berserk_Timer
@onready var timer_berserk_cooldown : Timer = $Timers/Attacks/Skill_Berserk_Cooldown
@onready var timer_berserk_dice_throw : Timer = $Timers/Attacks/Skill_Berserk_DiceThrow_Timer


func _ready():
	WaveManager.register_enemy(self)
	
	carriage = get_tree().get_first_node_in_group("carriage")
	
	health = max_health
	
	animation_tree.active = true
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_idle)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_walk)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_attack)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_getHit)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_skillBerserk)
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
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
	is_looking_left = position.direction_to(target.position).x < 0
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

func enough_damage_to_die(damage):
	return health-max(damage-defense,0) <= 0

func receive_damage(damage):
	# receive damage
	health -= max(damage-defense,0)
	
	if health <= 0:
		state_chart.send_event("sce_die")
	else:
		combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
		# if not is_berserk and timer_animation_dict["attack"].is_stopped():
		state_chart.send_event("sce_get_hit")
	pass

# is called in attack animation
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
	
	# throw a dice for skill usage
	var is_using_skill : bool = use_skill()
	
	if is_using_skill:
		state_chart.send_event("sce_berserk_start")
	else: # use normal attack
		# regulate attack inverval
		if timer_attack.is_stopped():
			state_chart.send_event("sce_attack")
	pass

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

func use_skill():
	var is_using_skill : bool
	# dice throw timer regulates the cooldown time for the AI
	# to decide on any skill
	if timer_berserk_cooldown.is_stopped():
		if timer_berserk_dice_throw.is_stopped():
			timer_berserk_dice_throw.start()
			# magic number, feels good for now
			# todo: implementing a skill pool
			is_using_skill = randi_range(0,1000) > 970
	return is_using_skill 

func _on_get_hit_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_getHit].is_stopped():
		state_chart.send_event("sce_old_state")
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
	timer_attack.start()
	animation_state_machine.travel(anim_state_attack)
	pass


func _on_get_hit_state_entered():
	timer_animation_dict[anim_state_getHit].start()
	animation_state_machine.travel(anim_state_getHit)
	pass # Replace with function body.

func _on_die_state_entered():
	# spawn skull / resource
	WaveManager.unregister_enemy(self)
	queue_free()
	pass # Replace with function body.

# !Exit!
func _on_move_to_target_state_exited():
	velocity = Vector2.ZERO
	pass # Replace with function body.

# BERSERK MODE ------------------

func _on_berserk_move_to_target_state_physics_processing(_delta):
	# reset berserk mode	
	if timer_berserk_duration.is_stopped():
		state_chart.send_event("sce_berserk_stop")
		return
		
	find_next_target()
	if target == null:
		return
	
	# move to target
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	
	if attack_area_melee_r.overlaps_body(target.body2D) \
	or attack_area_melee_l.overlaps_body(target.body2D):
		target_focused = target
		state_chart.send_event("sce_attack")
	
	pass

func _on_berserk_attack_state_physics_processing(_delta):
	if timer_berserk_duration.is_stopped():
		state_chart.send_event("sce_berserk_stop")
		
	if target == null:
		state_chart.send_event("sce_move_to_target")
		return
		
	# regulate attack interval
	if timer_berserk_attack.is_stopped():
		timer_berserk_attack.start()
		target.receive_damage(attack_damage)
		animation_state_machine.travel(anim_state_skillBerserk)
	pass # Replace with function body.

func _on_berserk_move_to_target_state_entered():
	animation_state_machine.travel(anim_state_walk)
	pass # Replace with function body.

func _on_berserk_attack_state_entered():
	animation_state_machine.travel(anim_state_skillBerserk)
	pass # Replace with function body.

func _on_mode_berserk_state_entered():
	sprite.modulate = Color(1, (180.0 / 255.0), (180.0 / 255.0))
	timer_berserk_duration.start()
	# cooldown applies when the mode is entered
	# can be changed to exited
	timer_berserk_cooldown.start() 
	pass

func _on_mode_berserk_state_exited():
	sprite.modulate = Color(1,1,1)
	pass



