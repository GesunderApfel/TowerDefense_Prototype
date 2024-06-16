extends Node2D

var enemy = preload("res://scenes/test/enemy.tscn")
var amount
#var meleecount
#var rangedcount
#var supportcount

func _ready():
	amount = 6
	$Start.start()

func _process(delta):
	pass

#func setcounts(mc, rc, sc):
	#meleecount = mc
	#rangedcount = rc
	#supportcount = sc

func spawnEnemy():
	var r = randi() % 2
	var spawn = enemy.instantiate()
	spawn.position = Vector2(800 + (800 + randf_range(0,300))*pow(-1,r),880)
	$Node.add_child(spawn)

func _on_start_timeout():
	var i = 0
	while i < amount:
		spawnEnemy()
		i+=1
	$Start.stop()
