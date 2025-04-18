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

# Arrows
const ARROW = preload("res://scenes/combat/combat_test/arrow.tscn")
@onready var arrow_spawn_marker = $Attacks/ArrowSpawnMarker
var attack_damage = 2


func _ready():
	animation_tree.active = true
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_pullArrow)
		
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_releaseArrow)
	
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
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
	arrow.global_position = arrow_spawn_marker.global_position
	
	var direction : Vector2 = (get_global_mouse_position()-arrow.global_position).normalized()
	arrow.set_direction(direction)
	arrow.set_collision_masks([1])
	arrow.set_damage_value(attack_damage)
		
	pass
	
# ##############
# State Chart  #
# ##############

# processing states
# state chart event prefix => sce_..

func _on_idle_state_processing(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		state_chart.send_event("sce_attack_pull")
	pass

func _on_attack_pull_state_processing(_delta):
	if timer_animation_dict[anim_state_pullArrow].is_stopped():
		state_chart.send_event("sce_attack_hold")
	pass

func _on_attack_hold_state_processing(_delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		state_chart.send_event("sce_attack_release");
	pass

func _on_attack_release_state_processing(_delta):
	if timer_animation_dict[anim_state_releaseArrow].is_stopped():
		state_chart.send_event("sce_idle")
	pass

# entering states

func _on_idle_state_entered():
	pass

func _on_attack_pull_state_entered():
	animation_state_machine.travel(anim_state_pullArrow)
	timer_animation_dict[anim_state_pullArrow].start()
	pass


func _on_attack_hold_state_entered():
	animation_state_machine.travel(anim_state_holdArrow)
	pass


func _on_attack_release_state_entered():
	animation_state_machine.travel(anim_state_releaseArrow)
	timer_animation_dict[anim_state_releaseArrow].start()
	shoot_arrow()
	pass # Replace with function body.





