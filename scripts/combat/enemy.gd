extends CharacterBody2D

enum CombatMovementType {
	GROUNDED, 
	FLYING,
}

enum CombatAttackType {
	MELEE,
	RANGED,
	SUPPORT,
}

enum EnemyState {
	GO_TO_TARGET,
	ATTACK_TARGET,
	GET_HIT,
	DYING,
}


var current_state := EnemyState.GO_TO_TARGET

# Attributes in DTO? Allows for composition instead of inheritance...
var health = 100
var move_speed = 120
var attack_damage = 1
var defense = 1
var attack_frequence = 2.5 #in seconds

# attack
var can_attack : bool = true
var is_berserk: bool = true

var target #what is the next target of action -> for now carriage

@export var combat_movement_type = CombatMovementType.GROUNDED
@export var combat_attack_type = CombatAttackType.MELEE

# Animation
@onready var animation_tree = $Animator/AnimationTree
@onready var sprite = $Animator/AnimatedSprite2D
var is_looking_left = false

# Physics & Colliders
@onready var collision_shape_2d = $CollisionShape2D
@onready var areas_facing_right = $Areas_FacingRight
@onready var areas_facing_left = $Areas_FacingLeft

@onready var attack_area_melee_r = $Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas_FacingLeft/AttackArea_Melee_L

# Timers
@onready var attack_timer = $Timers/Attacks/AttackTimer
@onready var skill_berserk_duration = $Timers/Attacks/Skill_Berserk_Duration
@onready var skill_berserk_timer = $Timers/Attacks/Skill_Berserk_Timer
@onready var skill_berserk_cooldown = $Timers/Attacks/Skill_Berserk_Cooldown
@onready var skill_berserk_dice_throw_timer = $Timers/Attacks/Skill_Berserk_DiceThrow_Timer


func _ready():
	animation_tree.active = true

func _physics_process(delta):
	
	if target == null:
		return
	
	sprite.flip_h = is_looking_left		
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
	animation_tree.set("parameters/conditions/IsWalking", true)
	animation_tree.set("parameters/conditions/IsAttacking", false)
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	
	if attack_area_melee_r.overlaps_body(target.body2D) \
	or attack_area_melee_l.overlaps_body(target.body2D):
		current_state = EnemyState.ATTACK_TARGET
		animation_tree.set("parameters/conditions/IsWalking", false)
		animation_tree.set("parameters/conditions/IsAttacking", true)
	pass

func attack():
	
	var is_using_skill : bool = false
	
	# is skill possible?
	if skill_berserk_duration.is_stopped():
		animation_tree.set("parameters/conditions/IsBerserk", false)
		is_berserk = false
		sprite.modulate = Color(1,1,1)
		if skill_berserk_cooldown.is_stopped():
			if skill_berserk_dice_throw_timer.is_stopped():
				skill_berserk_dice_throw_timer.start()
				is_using_skill = randi_range(0,1000) > 970
	
	if is_using_skill:
		sprite.modulate = Color(1,180.0 / 255.0,180.0 / 255.0)
		skill_berserk_duration.start()
		skill_berserk_cooldown.start()
		is_berserk = true
		animation_tree.set("parameters/conditions/IsAttacking", false)
		animation_tree.set("parameters/conditions/IsBerserk", true)
	else:	
		if is_berserk:
			if skill_berserk_timer.is_stopped():
				skill_berserk_timer.start()
				target.take_damage(attack_damage)
		else:
			if attack_timer.is_stopped():
				attack_timer.start()
				target.take_damage(attack_damage)
				animation_tree.set("parameters/conditions/IsAttacking", true)
			else:
				animation_tree.set("parameters/conditions/IsAttacking", false)


	# needs a kind of frequency -> timer for now
	# decide if skill or normal attack -> for now just attack
	# play animation -> use animator
	# apply damage to target -> for now instant (start of animation), in the
	# future must be triggered by animator event so the timing is accurate 
	pass

func die():
	# play die animation
	# remove object from scene -> later from animator event, 
	# for now just a 3 second delay or smth
	pass

func get_hit():
	# play get hit animation
	pass

func receive_damage(damage):
	# receive damage
	health -= damage
	if health <= 0:
		current_state= EnemyState.DYING
	else:
		current_state= EnemyState.GET_HIT
	pass
