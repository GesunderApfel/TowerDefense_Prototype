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

var animator #object which controls animations and events (e.g. animation_end) 
# -> probably in-build timeline, must be possible to create different variants
# TODO research if possible with resource file type (see player_skills)
# if not, we can create a custom node for each combat participiant and name the events the same 

@export var combat_movement_type = CombatMovementType.GROUNDED
@export var combat_attack_type = CombatAttackType.MELEE

func _process(delta):
	if target == null:
		return
	
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




