extends Node

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




enum combat_movement_type {
	grounded, 
	flying,
}

enum combat_attack_type {
	melee,
	ranged,
	support,
}

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

func receive_damage(damage):
	# play animation
	# receive damage
	health -= damage
	pass




