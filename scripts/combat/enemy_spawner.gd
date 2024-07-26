extends Node2D

const ENEMY_SCN = preload("res://scenes/combat/combat_test/enemy.tscn")
const ENEMY_FLYING = preload("res://scenes/combat/combat_test/enemy_flying.tscn")

var current_enemies_on_field : int = 0
var spawns = {
		1:[GROUNDED,GROUNDED,GROUNDED,GROUNDED,GROUNDED],
		2:[GROUNDED, FLYING, GROUNDED, GROUNDED, FLYING, FLYING, GROUNDED, FLYING],
		3:[],} 

var spawns_spawn_rate = {
		1:3,
		2:2,
		3:1,} 

enum {
	GROUNDED,
	FLYING,
}

# User Interface
@export var carriage : Node #allows referencing node via editor

@export var enemy_amount = 1

@export_range(0,10000) var ground_height = 880
@export var spawn_offset = Vector2(900,1200) # y value is for flying monsters

func _ready():
	#$Start.start()
	CombatDebug.bind_debug_method(spawn_enemy_left,"Grounded Enemy Left", KEY_1)
	CombatDebug.bind_debug_method(spawn_enemy_right,"Grounded Enemy Right", KEY_2)
	CombatDebug.bind_debug_method(spawn_flying_enemy_left,"Grounded Enemy Left", KEY_5)
	CombatDebug.bind_debug_method(spawn_flying_enemy_right,"Grounded Enemy Right", KEY_6)

func _process(delta):
	pass


func spawn_enemy():
	var enemy = ENEMY_SCN.instantiate()
	enemy.target = carriage
	enemy.carriage = carriage
	
	var horizontal_spawn_direction : int = 0
	
	if(randi_range(0,1) == 0):
		horizontal_spawn_direction = 1
		enemy.is_looking_left = true
	else:
		horizontal_spawn_direction = -1
		enemy.is_looking_left = false
		
	var pos_x : float = carriage.position.x + spawn_offset.x * horizontal_spawn_direction
	
	enemy.position = Vector2(pos_x,ground_height)
	$Enemies.add_child(enemy)

func spawn_enemy_left():
	var enemy = ENEMY_SCN.instantiate()
	enemy.target = carriage
	enemy.carriage = carriage
	
	enemy.is_looking_left = false
	var pos_x : float = carriage.position.x + spawn_offset.x * -1
	
	enemy.position = Vector2(pos_x,ground_height)
	$Enemies.add_child(enemy)
	
func spawn_enemy_right():
	var enemy = ENEMY_SCN.instantiate()
	enemy.target = carriage
	enemy.carriage = carriage
	
	enemy.is_looking_left = true
	var pos_x : float = carriage.position.x + spawn_offset.x * 1
	
	enemy.position = Vector2(pos_x,ground_height)
	$Enemies.add_child(enemy)
	
func spawn_flying_enemy_left():
	var enemy = ENEMY_FLYING.instantiate()
	enemy.target = carriage
	enemy.carriage = carriage
	
	enemy.is_looking_left = false
	var pos_x : float = carriage.position.x + spawn_offset.x * -1
	
	enemy.position = Vector2(pos_x,ground_height - spawn_offset.y)
	$Enemies.add_child(enemy)
	
func spawn_flying_enemy_right():
	var enemy = ENEMY_FLYING.instantiate()
	enemy.target = carriage
	enemy.carriage = carriage
	
	enemy.is_looking_left = true
	var pos_x : float = carriage.position.x + spawn_offset.x * 1
	
	enemy.position = Vector2(pos_x,ground_height - spawn_offset.y)
	$Enemies.add_child(enemy)
