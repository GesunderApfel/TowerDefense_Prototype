extends Node2D

const TEST_ENEMY_SCN = preload("res://scenes/combat/combat_test/test_enemy.tscn")

@export var enemy_amount = 1

@export_range(0,10000) var ground_height = 880
@export var spawn_offset = Vector2(900,1200) # y value is for flying monsters

func _ready():
	#$Start.start()
	CombatDebug.initialize_combat_debug_ui()
	CombatDebug.bind_debug_method(spawnEnemy,"Spawn Enemy")


func _process(delta):
	pass


func spawnEnemy():
	var horizontal_spawn_direction = 1 if(randi_range(0,1) == 0) else -1 #ternary operation
	var spawn = TEST_ENEMY_SCN.instantiate()
	
	spawn.position = Vector2(spawn_offset.x * horizontal_spawn_direction,ground_height)
	$Enemies.add_child(spawn)


#func _on_start_timeout():
	#var i = 0
	#while i < enemy_amount:
		#spawnEnemy()
		#i+=1
	#$Start.stop()
