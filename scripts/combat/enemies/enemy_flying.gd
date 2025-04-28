extends CharacterBody2D

@onready var state_chart = $StateChart

const FIREBALL = preload("res://scenes/combat/combat_test/fireball.tscn")

@onready var sprite = $Animator/AnimatedSprite2D
@onready var body2d = $CS2D_BodyCollider
@onready var combat_health_bar = $CombatHealthBar


# animations
@onready var animation_tree = $Animator/AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback
const anim_state_idle = "idle"
const anim_state_move = "move"
const anim_state_attack = "attack"
const anim_state_getHit = "get_hit"
const anim_state_die = "die"

# physics
@onready var area_scan_radius = $Areas/Area_ScanRadius
@onready var area_attack_range = $Areas/Area_AttackRange

# timers
var timer_animation_dict : Dictionary = {}
@onready var timer_attack_interval = $Timers/Attacks/Timer_AttackInterval


# members
var health
var max_health := 4
var move_speed := 80
@export var attack := 2
var defense := 0

var carriage:Node
var target:Node
var target_focused:Node

var is_looking_left

func _ready():
	WaveManager.register_enemy(self)
	
	carriage = get_tree().get_first_node_in_group("carriage")
	
	health = max_health
	
	animation_tree.active = true
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_idle)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_move)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_attack)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_getHit)
	UtilityStateMachine.create_timer_for_animation\
		(self,animation_tree, timer_animation_dict,anim_state_die)
	animation_state_machine = UtilityStateMachine.get_playback(animation_tree)
	pass

func _physics_process(_delta):
	if target_focused == null:
		find_target()
	else:
		target = target_focused
	
	look_at_target()
	pass

func find_target():
	var nextTarget:Node
	var nearest_distance:= 10000.0
	
	# chooses the nearest target in scan range
	for body in area_scan_radius.get_overlapping_bodies():
		if body.is_in_group("carriage") or body.is_in_group("ally"):
			if position.distance_to(body.position) < nearest_distance:
				nearest_distance = position.distance_to(body.position)
				nextTarget = body
	
	if nextTarget:
		target = nextTarget
	else:
		target = carriage
	pass

func look_at_target():
	is_looking_left = position.direction_to(target.position).x < 0
	sprite.flip_h = is_looking_left
	pass

func receive_damage(damage):
	health -= max(damage-defense,0)

	if health <= 0:
		state_chart.send_event("sce_die")
	else:
		combat_health_bar.update_health_value(float(health) / float(max_health) * 100.0)
		state_chart.send_event("sce_get_hit")
	pass

## is called by animation track "attack" to ensure correct timing
func spawn_projectile():
	if not target_focused:
		return
	
	var fireball = FIREBALL.instantiate()
	self.add_child(fireball)
	fireball.global_position = global_position
	
	# shoot into target direction
	var direction : Vector2 = (target_focused.global_position \
	-fireball.global_position + Vector2(0,-65)).normalized()
	fireball.set_direction(direction)
	fireball.set_collision_masks([2,3])
	fireball.set_damage_value(attack)
	pass



# ################
# State Handling
# ################

func _on_move_state_physics_processing(_delta):
	# is monster in attack range to target?
	if area_attack_range.overlaps_body(target.body2D):
		target_focused = target
		timer_attack_interval.start()
		state_chart.send_event("sce_attack")
		return
	
	# move to target
	velocity = position.direction_to(target.position) * move_speed
	move_and_slide()
	pass

func _on_idle_state_physics_processing(_delta):
	# target died or was not assigned
	if target_focused == null:
		state_chart.send_event("sce_move")
		return
	
	# target not in range anymore
	if not area_attack_range.overlaps_body(target_focused.body2D):
		state_chart.send_event("sce_move")
		return
	
	if timer_attack_interval.is_stopped():
		state_chart.send_event("sce_attack")
		return
	pass


func _on_attack_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_attack].is_stopped():
		state_chart.send_event("sce_idle")
	pass 


func _on_dying_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_die].is_stopped():
		WaveManager.unregister_enemy(self)
		queue_free()
	pass
	

func _on_get_hit_state_physics_processing(_delta):
	if timer_animation_dict[anim_state_getHit].is_stopped():
		state_chart.send_event("sce_old_state")
	pass

# ######
# handle transitions
# ######
func _on_move_state_entered():
	animation_state_machine.travel(anim_state_move)
	pass

func _on_attack_state_entered():
	timer_animation_dict[anim_state_attack].start()
	timer_attack_interval.start()
	animation_state_machine.travel(anim_state_attack)
	pass

func _on_attack_target_state_entered():
	# cooldown time before starting attack
	timer_attack_interval.start()
	pass

func _on_idle_state_entered():
	animation_state_machine.travel(anim_state_idle)
	pass

func _on_dying_state_entered():
	animation_state_machine.travel(anim_state_die)
	timer_animation_dict[anim_state_die].start()
	pass

func _on_get_hit_state_entered():
	animation_state_machine.travel(anim_state_getHit)
	timer_animation_dict[anim_state_getHit].start()
	pass



