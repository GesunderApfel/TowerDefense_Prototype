extends CharacterBody2D

const SPEED = 300.0
var TARGET
var attack_range
enum type_enum {melee,
				ranged,
				support,
				}

func _ready():
	var r = randi() % 2
	if r == 0:
		$CollisionShape2D/MeshInstance2D.show()
		$CollisionShape2D/MeshInstance2D2.hide()
		attack_range = 100
	else:
		$CollisionShape2D/MeshInstance2D2.show()
		$CollisionShape2D/MeshInstance2D.hide()
		attack_range = 500

func _physics_process(delta):
	find_target()
	move_to_target(delta)

func find_target():
	var carriage = get_tree().get_first_node_in_group("ride")
	TARGET = carriage
	var distance = abs(TARGET.global_position.x - position.x)
	var targets = get_tree().get_nodes_in_group("ally")
	for t in targets :
		var d = abs(t.global_position.x - position.x) 
		if d < distance:
			TARGET = t
			distance = d

func move_to_target(delta):
	if abs(TARGET.global_position.x - position.x) > attack_range:
		var d = (TARGET.global_position - global_position).normalized()
		position += d * SPEED * delta
