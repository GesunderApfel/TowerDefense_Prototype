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
var spawning = false # true as long as a wave is spawning enemies
var is_wave_finished = false

# UI #
@onready var label_wave = $CanvasLayer/UI/WaveLabel
@onready var label_enemy_counter = $CanvasLayer/UI/EnemyCounter
@onready var label_wave_countdown = $CanvasLayer/UI/WaveCountdown
var next_wave_time := 0.0


func _ready():
	start_next_wave()
	WaveManager.connect("last_enemy_killed", Callable(self, "finish_wave"))
	pass

func _process(delta):
	update_wave_countdown()
	pass

func start_next_wave():
	if current_wave >= waves.size():
		print("All waves finished!")
		return
	
	print("Start wave ", current_wave + 1)
	spawning = true
	is_wave_finished = false
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
	
	update_ui_for_wave_start()
	pass

func generate_spawn_entry(scene: PackedScene, spawn_L: Node2D, spawn_R: Node2D):
	var spawn_left = randi() % 2 == 0
	var spawn_point = spawn_L if spawn_left else spawn_R
	return {"scene": scene, "position": spawn_point.global_position}


func spawn_enemies_with_delay(spawn_tasks: Array, wave: int):
	if spawn_tasks.is_empty():
		spawnig_complete()
		return
	
	
	var task = spawn_tasks.pop_front()
	var enemy = task["scene"].instantiate()
	enemy.global_position = task["position"]
	get_tree().current_scene.call_deferred("add_child",enemy)
	
	await get_tree().create_timer(waves[wave].spawn_delay_between_enemies).timeout
	spawn_enemies_with_delay(spawn_tasks, wave)
	pass


func spawnig_complete():
	print("Wave ", current_wave + 1, " spawning complete.")
	spawning = false
	current_wave += 1
	pass

#TODO
# wird jetzt ausgeführt sobald der letzte Gegner einer Wave stirbt. 
func finish_wave():
	is_wave_finished = true
	if current_wave >= waves.size():
		return
	
	next_wave_time = Time.get_unix_time_from_system() \
					+ waves[current_wave].time_until_next_wave
	await get_tree().create_timer(waves[current_wave].time_until_next_wave).timeout
	start_next_wave()
	pass

# ##############
# UI ###########
# ##############

func update_ui_for_wave_start():
	show_wave_number()
	update_enemy_counter()
	update_wave_countdown()
	pass

func show_wave_number():
	label_wave.text = "Wave %d" % (current_wave + 1)
	label_wave.modulate.a = 1.0
	label_wave.scale = Vector2(0.1, 0.1)
	label_wave.show()
	
	var tween = create_tween()
	tween.tween_property(label_wave, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.0)
	tween.tween_property(label_wave, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label_wave.hide)
	pass

func update_enemy_counter():
	if current_wave +1 >= waves.size():
		label_enemy_counter.text = "No new enemies coming."
		label_enemy_counter.hide()
		return
	
	var enemy_count = waves[current_wave].grounded \
					+ waves[current_wave].flying \
					+ waves[current_wave].boss
	
	label_enemy_counter.text = "New Enemies: %d" % enemy_count
	pass

func update_wave_countdown():
	if not is_wave_finished:
		label_wave_countdown.text = "Ongoing wave."
	else:
		if current_wave < waves.size():
			var remaining_time = max(0,next_wave_time - Time.get_unix_time_from_system())
			label_wave_countdown.text = "Next wave in %.1fs" % remaining_time
		else:
			label_wave_countdown.text = "No more waves coming."
	pass
