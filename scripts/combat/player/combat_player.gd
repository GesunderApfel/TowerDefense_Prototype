extends Node2D


@onready var state_chart = $StateChart
@onready var body2D = $CharacterBody2D
@onready var sprite = $Visuals/AnimatedSprite2D
var is_looking_left : bool = false


# animation
@onready var animation_tree = $Visuals/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback
var timer_animation_dict = {}

const anim_state_idle = "idle"
const anim_state_pullArrow = "pull_arrow"
const anim_state_holdArrow = "hold_arrow"
const anim_state_releaseArrow = "release_arrow"

# Bow & Arrows
@onready var bow = $Visuals/Bow
const ARROW = preload("res://scenes/combat/combat_test/arrow.tscn")
var attack_damage = 2

@onready var bow_animation_tree = $Visuals/Bow/BowAnimationTree
var bow_animation_state_machine : AnimationNodeStateMachinePlayback
var timer_bow_animation_dict = {}
const bow_anim_state_hold = "hold"
const bow_anim_state_release = "release"

func _ready():
	animation_tree.active = true
		
	# player character
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_pullArrow)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_releaseArrow)
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
	
	# bow & arrow
	UtilityStateMachine.create_timer_for_animation\
		(self,bow_animation_tree, timer_bow_animation_dict,bow_anim_state_hold)
	UtilityStateMachine.create_timer_for_animation\
		(self,bow_animation_tree, timer_bow_animation_dict,bow_anim_state_release)
	bow_animation_state_machine = UtilityStateMachine.get_playback(bow_animation_tree)
	pass

func _process(_delta):
	update_look_direction()
	sprite.flip_h = is_looking_left
	pass

func update_look_direction():
	if get_global_mouse_position() < global_position:
		is_looking_left = true
	else:
		is_looking_left = false
	pass

## shoots an arrow to the mouse position
func shoot_arrow():	
	var arrow = ARROW.instantiate()
	self.add_child(arrow)
	arrow.global_position = bow.global_position
	
	var direction : Vector2 = (get_global_mouse_position()-arrow.global_position).normalized()
	arrow.set_direction(direction)
	arrow.set_collision_masks([1])
	arrow.set_damage_value(attack_damage)
		
	pass
	
# ##############
# State Chart  #
# ##############

func _on_idle_state_processing(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		state_chart.send_event("sce_attack_pull")
	pass

func _on_attack_pull_state_processing(_delta):
	if timer_animation_dict[anim_state_pullArrow].is_stopped():
		state_chart.send_event("sce_attack_hold")
	pass


func _on_attack_hold_state_processing(_delta):
	var to_mouse = get_viewport().get_mouse_position() - bow.global_position
	bow.rotation = to_mouse.angle()
	
	# flip bow
	if bow.rotation > PI/2 or bow.rotation < -PI/2:
		bow.scale.y = -1.0
	else:
		bow.scale.y = 1.0
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		state_chart.send_event("sce_attack_release");
	pass

func _on_attack_release_state_processing(_delta):
	if timer_bow_animation_dict[bow_anim_state_release].is_stopped():
		state_chart.send_event("sce_idle")
		bow.hide()
	pass

# ######################
# Handling Transitions #
# ######################

func _on_idle_state_entered():
	animation_state_machine.travel(anim_state_idle)
	pass

func _on_attack_pull_state_entered():
	animation_state_machine.travel(anim_state_pullArrow)
	timer_animation_dict[anim_state_pullArrow].start()
	pass


func _on_attack_hold_state_entered():
	animation_state_machine.travel(anim_state_holdArrow)
	
	bow.show()
	bow_animation_state_machine.travel(bow_anim_state_hold)
	pass


func _on_attack_release_state_entered():
	animation_state_machine.travel(anim_state_releaseArrow)
	timer_animation_dict[anim_state_releaseArrow].start()
	
	bow_animation_state_machine.travel(bow_anim_state_release)
	timer_bow_animation_dict[bow_anim_state_release].start()
	
	shoot_arrow()
	pass





