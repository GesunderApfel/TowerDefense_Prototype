extends CharacterBody2D

enum EnemyState {
	GO_TO_TARGET,
	ATTACK_TARGET,
	GET_HIT,
	DYING,
}

enum AnimationTreeState{
	IDLE,
	WALKING,
	ATTACKING,
	SKILL_BERSERK,
	GETTING_HIT,	
}


var carriage
var body2D : Node = self


var current_state := EnemyState.GO_TO_TARGET
var return_state := EnemyState.GO_TO_TARGET
# Attributes in DTO? Allows for composition instead of inheritance...
var health
var max_health = 10
var move_speed = 120
@export var attack_damage = 1
var defense = 0
var attack_frequence = 2.5 #in seconds

# attack
var is_berserk: bool = false
@onready var combat_health_bar = $CombatHealthBar

var target:Node
var target_focused:Node


# Animation
@onready var animation_tree = $Animator/AnimationTree
@onready var sprite = $Animator/AnimatedSprite2D
var is_looking_left = false

# Physics & Colliders
@onready var collision_shape_2d = $CollisionShape2D
@onready var areas_facing_right = $Areas/Areas_FacingRight
@onready var areas_facing_left = $Areas/Areas_FacingLeft

@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_scan_radius = $Areas/Area_ScanRadius

# Timers
var timer_animation_dict : Dictionary = {}
@onready var attack_timer : Timer = $Timers/Attacks/AttackTimer
@onready var skill_berserk_duration : Timer = $Timers/Attacks/Skill_Berserk_Duration
@onready var skill_berserk_timer : Timer = $Timers/Attacks/Skill_Berserk_Timer
@onready var skill_berserk_cooldown : Timer = $Timers/Attacks/Skill_Berserk_Cooldown
@onready var skill_berserk_dice_throw_timer : Timer = $Timers/Attacks/Skill_Berserk_DiceThrow_Timer


func _ready():
	animation_tree.active = true
	health = max_health
	
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,"get_hit")
	
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,"attack")
		
	CombatDebug.bind_debug_method(debug_toggle_berserk,"Toggle Berserk")


func debug_toggle_berserk():
	if is_berserk:
		is_berserk = false
		skill_berserk_timer.stop()
		skill_berserk_duration.stop()
	else:
		is_berserk = true
		skill_berserk_duration.start()
		skill_berserk_timer.start()
		sprite.modulate = Color(1,180.0 / 255.0,180.0 / 255.0)
		animation_tree.set_current_state(AnimationTreeState.keys() \
			[AnimationTreeState.SKILL_BERSERK])
	pass


func _process(_delta):
	var animstatemachine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	
	print(animstatemachine.get_current_node())
	find_next_target()
	look_at_target()

func find_next_target():
	var nextTarget : Node
	var nearest_distance := 10000
	
	for body in area_scan_radius.get_overlapping_bodies():
		if body.is_in_group("ally"):
			if nearest_distance > position.distance_to(body.position):
				nearest_distance = position.distance_to(body.position)
				nextTarget = body

	if nextTarget == null:
		nextTarget  = carriage
	
	target = nextTarget
	# print(target.name)
	pass

func look_at_target():
	is_looking_left = position.direction_to(target.position).x < 0
	sprite.flip_h = is_looking_left
	

func _physics_process(delta):
	if target == null:
		return

	if is_looking_left:
		areas_facing_left.show()
		areas_facing_right.hide()
	else:
		areas_facing_right.show()
		areas_facing_left.hide()
	
	match current_state:
		EnemyState.GO_TO_TARGET:
			go_to_target()
		EnemyState.ATTACK_TARGET:
			attack()
		EnemyState.GET_HIT:
			get_hit()
		EnemyState.DYING:
			die()
		
	

func go_to_target():
	animation_tree.set_current_state(AnimationTreeState.keys() \
		[AnimationTreeState.WALKING])
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	
	if skill_berserk_duration.is_stopped():
		is_berserk = false
		sprite.modulate = Color(1,1,1)
	
	if attack_area_melee_r.overlaps_body(target.body2D) \
	or attack_area_melee_l.overlaps_body(target.body2D):
		current_state = EnemyState.ATTACK_TARGET
		target_focused = target
		
		if not is_berserk:
			animation_tree.set_current_state(AnimationTreeState.keys() \
				[AnimationTreeState.ATTACKING])
	pass

func attack():
	if not timer_animation_dict["attack"].is_stopped():
		return
	
	print("ATTACK STATE")
	if not target_focused:
		current_state = EnemyState.GO_TO_TARGET
		return
	
	var is_using_skill : bool = false
	
	# is skill possible?
	if skill_berserk_duration.is_stopped():
		animation_tree.set_current_state(AnimationTreeState.keys() \
			[AnimationTreeState.IDLE])
		is_berserk = false
		sprite.modulate = Color(1,1,1)
		if skill_berserk_cooldown.is_stopped():
			if skill_berserk_dice_throw_timer.is_stopped():
				skill_berserk_dice_throw_timer.start()
				is_using_skill = randi_range(0,1000) > 970
	
	if is_using_skill:
		go_berserk()
	else:	
		if is_berserk:
			if skill_berserk_timer.is_stopped():
				skill_berserk_timer.start()
				target.receive_damage(attack_damage)
				animation_tree.set_current_state(AnimationTreeState.keys() \
					[AnimationTreeState.SKILL_BERSERK])
		else:
			if attack_timer.is_stopped():
				attack_timer.start()
				timer_animation_dict["attack"].start()
				target.receive_damage(attack_damage)
				animation_tree.set_current_state(AnimationTreeState.keys() \
					[AnimationTreeState.ATTACKING])
			else:
				animation_tree.set_current_state(AnimationTreeState.keys() \
					[AnimationTreeState.IDLE])
	pass

func go_berserk():
	sprite.modulate = Color(1,180.0 / 255.0,180.0 / 255.0)
	skill_berserk_duration.start()
	skill_berserk_cooldown.start()
	is_berserk = true
	animation_tree.set_current_state(AnimationTreeState.keys() \
		[AnimationTreeState.SKILL_BERSERK])
	pass

func die():
	queue_free()
	pass

func get_hit():
	if timer_animation_dict["get_hit"].is_stopped():
		current_state = return_state
	# play get hit animation
	pass

func receive_damage(damage):
	# receive damage
	health -= max(damage-defense,0)
	if not current_state == EnemyState.GET_HIT:
		return_state = current_state
	combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
	
	if health <= 0:
		current_state= EnemyState.DYING
	else:
		if not is_berserk and timer_animation_dict["attack"].is_stopped():
			current_state= EnemyState.GET_HIT
			animation_tree.set_current_state(AnimationTreeState.keys() \
				[AnimationTreeState.GETTING_HIT])
			timer_animation_dict["get_hit"].start()
	pass
