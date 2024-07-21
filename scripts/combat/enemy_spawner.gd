extends Node2D

const TEST_ENEMY_SCN = preload("res://scenes/combat/combat_test/test_enemy.tscn")

@export var carriage : Node #allows referencing node via editor

@export var enemy_amount = 1

@export_range(0,10000) var ground_height = 880
@export var spawn_offset = Vector2(900,1200) # y value is for flying monsters

func _ready():
	#$Start.start()
	CombatDebug.bind_debug_method(spawn_enemy,"Spawn Enemy")


func _process(delta):
	pass


func spawn_enemy():
	var enemy = TEST_ENEMY_SCN.instantiate()
	enemy.target = carriage
	
	var horizontal_spawn_direction : int = 0
	
	if(randi_range(0,1) == 0):
		horizontal_spawn_direction = 1
		enemy.is_looking_left = true
	else:
		horizontal_spawn_direction = -1
		enemy.is_looking_left = false
		
	var pos_x : float = carriage.position.x + spawn_offset.x * horizontal_spawn_direction
	print(pos_x);
	
	enemy.position = Vector2(pos_x,ground_height)
	$Enemies.add_child(enemy)


#func _on_start_timeout():
	#var i = 0
	#while i < enemy_amount:
		#spawnEnemy()
		#i+=1
	#$Start.stop()
