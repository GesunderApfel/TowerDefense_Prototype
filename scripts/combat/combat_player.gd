extends Node2D

enum PLAYER_COMBAT_STATE{
	Idle,
	PullArrow,
	HoldArrow,
	ReleaseArrow,
}

var current_state : PLAYER_COMBAT_STATE = PLAYER_COMBAT_STATE.Idle

@onready var animation_tree = $Visuals/AnimationTree
@onready var sprite = $Visuals/AnimatedSprite2D

var timer_pull_arrow_animation : Timer
var timer_release_arrow_animation : Timer

var is_looking_left : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_look_direction()
	sprite.flip_h = is_looking_left
	
	match current_state:
		PLAYER_COMBAT_STATE.Idle:
			State_Idle()
		PLAYER_COMBAT_STATE.PullArrow:
			State_PullArrow()
		PLAYER_COMBAT_STATE.HoldArrow:
			State_HoldArrow()
		PLAYER_COMBAT_STATE.ReleaseArrow:
			State_ReleaseArrow()
	pass

func State_Idle():
	animation_tree.set("parameters/conditions/IsHoldingArrow", false)
	animation_tree.set("parameters/conditions/IsReleasingArrow", false)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_state = PLAYER_COMBAT_STATE.PullArrow
		timer_pull_arrow_animation.start()
	pass

func State_PullArrow():
	animation_tree.set("parameters/conditions/IsHoldingArrow", true)
	print("State_pullArrow")
	print(str(timer_pull_arrow_animation.is_stopped()) + "\n " + str(timer_pull_arrow_animation.time_left))
	if timer_pull_arrow_animation.is_stopped():
		current_state = PLAYER_COMBAT_STATE.HoldArrow	
	pass

func State_HoldArrow():	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_state = PLAYER_COMBAT_STATE.ReleaseArrow
		timer_release_arrow_animation.start()
		animation_tree.set("parameters/conditions/IsReleasingArrow",true)
		animation_tree.set("parameters/conditions/IsHoldingArrow",false)
		
		
		
		# spawn arrow
		# give arrow direction
	
	pass

func State_ReleaseArrow():
	animation_tree.set("parameters/conditions/IsReleasingArrow",true)
	
	if timer_release_arrow_animation.is_stopped():
		current_state = PLAYER_COMBAT_STATE.Idle	
	pass

func update_look_direction():
	if get_global_mouse_position() < global_position:
		is_looking_left = true
	else:
		is_looking_left = false
	pass
