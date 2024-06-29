extends Node

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
var move_speed = 10
var attack_damage = 1
var defense = 1
var attack_frequence = 5.0 #in seconds

var target #what is the next target of action -> for now carriage

@export var combat_movement_type = CombatMovementType.GROUNDED
@export var combat_attack_type = CombatAttackType.MELEE

# Animation
@onready var animation_tree = $EnemyAnimator/AnimationTree
@onready var sprite = $EnemyAnimator/AnimatedSprite2D
var is_looking_left = false

func _ready():
	animation_tree.active = true
	CombatDebug.bind_debug_method(debug_walk, "Enemy Walking")
	CombatDebug.bind_debug_method(debug_idle, "Enemy Idleing")
	CombatDebug.bind_debug_method(debug_toogle_look_direction, "Enemy Toogle Direction")

func _process(delta):
	if target == null:
		return
	
	sprite.flip_h = is_looking_left
	
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
	# walk animation
	# move to target
	# check if target is in attack range
	# if yes -> change state to attack
	pass

func attack():
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


func debug_walk():
	animation_tree.set("parameters/IsMoving/blend_position", 1)
	
func debug_idle():
	animation_tree.set("parameters/IsMoving/blend_position", 0)

func debug_toogle_look_direction():
	is_looking_left = not is_looking_left
	sprite.flip_h = is_looking_left
	
	



