extends Node2D

const FIRE_WALL \
 = preload("res://scenes/combat/combat_test/demon_lord_skill_fire_wall.tscn")

@onready var demon_lord = $"../.."
@onready var skill_firewall_spawn_timer = $FirewallSpawnerTimer

@export var damage = 1
@export var number_of_walls = 3
@export var spawn_offset = Vector2(50,0)

var wall_count

func _ready():
	wall_count = number_of_walls + 1
	# counter will be set to 0 for processing spawns
	pass
	
func _physics_process(_delta):
	if skill_firewall_spawn_timer.is_stopped():
		if wall_count <= number_of_walls:
			spawn_firewalls()
	pass

func spawn_firewalls():
	var wall_left = FIRE_WALL.instantiate()
	var wall_right = FIRE_WALL.instantiate()
	
	wall_left.damage = damage
	wall_right.damage = damage
	
	var offset = wall_count * spawn_offset
	wall_left.global_position = demon_lord.global_position - offset
	wall_right.global_position = demon_lord.global_position + offset
	
	get_tree().current_scene.add_child(wall_left)
	get_tree().current_scene.add_child(wall_right)
	
	wall_count+=1
	skill_firewall_spawn_timer.start()
	pass


func start_spawning_process():
	wall_count = 1
	pass
