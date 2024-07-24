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

var animation_timer_dict : Dictionary = {}

var current_state := AllyState.DEFEND_CARRIAGE


var carriage : Node
var target : Node

@export var carriage_defense_radius := 200.0

# members
var attack : int = 2
var health : int = 18
var move_speed : float = 200



# animation
@onready var sprite = $Visuals/AnimatedSprite2D
@onready var animation_tree = $Visuals/AnimationTree

# Physics
@onready var attack_area_melee_r = $Areas/Areas_FacingRight/AttackArea_Melee_R
@onready var attack_area_melee_l = $Areas/Areas_FacingLeft/AttackArea_Melee_L
@onready var area_attack_radius = $Areas/Area_AttackRadius

var is_looking_left : bool = false

func _ready():
	animation_tree.active = true
	
	var dyingTimer = Timer.new()
	dyingTimer.wait_time = animation_tree.get_animation("dying").length
	dyingTimer.one_shot = true
	animation_timer_dict[AnimationTreeState] = dyingTimer
	pass
	

func _physics_process(delta):
	match current_state:
		AllyState.DEFEND_CARRIAGE:
			state_defend_carriage()
		AllyState.ATTACK_TARGET:
			state_attack_target()
		AllyState.DYING:
			state_dying()
			
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
		animation_tree.current_state = AnimationTreeState.keys()[AnimationTreeState.IDLE]
		animation_tree.iswalking = false
		if is_carriage_left == is_looking_left:
			is_looking_left = not is_looking_left # turn player in next frame
	else:
		is_looking_left = is_carriage_left
		animation_tree.current_state = AnimationTreeState.keys()[AnimationTreeState.WALKING]
		animation_tree.iswalking = true
		velocity = move_speed * carriage_direction
		move_and_slide()
	pass

func state_attack_target():
	# if no enemies are in attack radius
	#	change state to DEFEND_CARRIAGE
	# if enemy is in hit range
	#	attack
	#	animation_tree.current_state = AnimationTreeState.ATTACKING
	# else
	#	walk to enemy
	#	animation_tree.current_state = AnimationTreeState.WALKING
		
	pass
	
var already_started_dying = false
func state_dying():
	if animation_timer_dict[AnimationTreeState.DYING].is_stopped():
		if already_started_dying:
			queue_free()
		else:
			animation_tree.current_state = AnimationTreeState.DYING
			animation_timer_dict[AnimationTreeState.DYING].start()
		pass
	queue_free()
	pass



