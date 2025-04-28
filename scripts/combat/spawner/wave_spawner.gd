extends Node

@export var grounded_enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene

@export var grounded_spawn_point_L: Node2D
@export var grounded_spawn_point_R: Node2D

@export var flying_spawn_point_L: Node2D
@export var flying_spawn_point_R: Node2D

@export var waves: Array[WaveData] = []

var current_wave = 0
var spawning = false

func _ready():
	start_next_wave()
	pass

func start_next_wave():
	if current_wave >= waves.size():
		print("All waves finished!")
		return
	
	print("Start wave ", current_wave + 1)
	spawning = true
	spawn_wave(waves[current_wave])
	pass

func spawn_wave(wave_data: WaveData):
	var spawn_pool = []
	
	for i in wave_data.grounded:
		spawn_pool.append(generate_spawn_entry \
			(grounded_enemy_scene, grounded_spawn_point_L, grounded_spawn_point_R))
	
	if wave_data.flying > 0:
		spawn_pool.append(generate_spawn_entry \
			(flying_enemy_scene, flying_spawn_point_L, flying_spawn_point_R))
	
	if wave_data.boss > 0:
		spawn_pool.append(generate_spawn_entry \
			(boss_enemy_scene, grounded_spawn_point_L, grounded_spawn_point_R))
	
	spawn_pool.shuffle()
	spawn_enemies_with_delay(spawn_pool, current_wave)
	pass

func generate_spawn_entry(scene: PackedScene, spawn_L: Node2D, spawn_R: Node2D):
	var spawn_left = randi() % 2 == 0
	var spawn_point = spawn_L if spawn_left else spawn_R
	return {"scene": scene, "position": spawn_point.global_position}


func spawn_enemies_with_delay(spawn_tasks: Array, wave: int):
	if spawn_tasks.is_empty():
		finish_wave()
		return

	var task = spawn_tasks.pop_front()
	var enemy = task["scene"].instantiate()
	enemy.global_position = task["position"]
	get_tree().current_scene.call_deferred("add_child",enemy)
	
	await get_tree().create_timer(waves[wave].spawn_delay_between_enemies).timeout
	spawn_enemies_with_delay(spawn_tasks, wave)
	pass

func finish_wave():
	print("Wave ", current_wave + 1, " complete.")
	spawning = false
	current_wave += 1
	await get_tree().create_timer(waves[current_wave].time_until_next_wave).timeout
	start_next_wave()
	pass
