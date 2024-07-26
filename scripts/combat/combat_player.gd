extends Node2D

enum PlayerCombatState{
	IDLE,
	PULL_ARROW,
	HOLD_ARROW,
	RELEASE_ARROW,
}

var current_state : PlayerCombatState = PlayerCombatState.IDLE

@onready var body2D = $CharacterBody2D

const ARROW = preload("res://scenes/combat/combat_test/arrow.tscn")

@onready var animation_tree = $Visuals/AnimationTree
@onready var sprite = $Visuals/AnimatedSprite2D

var timer_pull_arrow_animation : Timer
var timer_release_arrow_animation : Timer

var is_looking_left : bool = false


# stats
var attack_damage = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	
	timer_pull_arrow_animation = Timer.new()
	timer_pull_arrow_animation.one_shot = true
	timer_pull_arrow_animation.wait_time \
		= animation_tree.get_animation("pull_arrow").length
	
	timer_release_arrow_animation = Timer.new()
	timer_release_arrow_animation.one_shot = true
	timer_release_arrow_animation.wait_time \
		= animation_tree.get_animation("release_arrow").length
		
	self.add_child(timer_pull_arrow_animation)
	self.add_child(timer_release_arrow_animation)
	pass


func _process(delta):
	update_look_direction()
	sprite.flip_h = is_looking_left
	
	match current_state:
		PlayerCombatState.IDLE:
			state_idle()
		PlayerCombatState.PULL_ARROW:
			state_pull_arrow()
		PlayerCombatState.HOLD_ARROW:
			state_hold_arrow()
		PlayerCombatState.RELEASE_ARROW:
			state_release_arrow()
	pass

func state_idle():
	animation_tree.set("parameters/conditions/IsHoldingArrow", false)
	animation_tree.set("parameters/conditions/IsReleasingArrow", false)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_state = PlayerCombatState.PULL_ARROW
		timer_pull_arrow_animation.start()
	pass

func state_pull_arrow():
	animation_tree.set("parameters/conditions/IsHoldingArrow", true)
	if timer_pull_arrow_animation.is_stopped():
		current_state = PlayerCombatState.HOLD_ARROW	
	pass

func state_hold_arrow():	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_state = PlayerCombatState.RELEASE_ARROW
		timer_release_arrow_animation.start()
		animation_tree.set("parameters/conditions/IsReleasingArrow",true)
		animation_tree.set("parameters/conditions/IsHoldingArrow",false)
		
		var arrow = ARROW.instantiate()
		self.add_child(arrow)
		arrow.global_position = global_position + Vector2(0,-65)
		
		var direction : Vector2 = (get_global_mouse_position()-arrow.global_position).normalized()
		arrow.set_direction(direction)
		arrow.set_collision_masks([1])
		arrow.set_damage_value(attack_damage)
		
	pass

func state_release_arrow():
	animation_tree.set("parameters/conditions/IsReleasingArrow",true)
	
	if timer_release_arrow_animation.is_stopped():
		current_state = PlayerCombatState.IDLE
	pass

func update_look_direction():
	if get_global_mouse_position() < global_position:
		is_looking_left = true
	else:
		is_looking_left = false
	pass
