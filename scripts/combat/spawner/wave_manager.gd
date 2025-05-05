extends Node

signal last_enemy_killed
var living_enemies : Array[Node2D] = []

func register_enemy(enemy: Node2D):
	living_enemies.append(enemy)
	pass

func unregister_enemy(enemy: Node2D):
	living_enemies.erase(enemy)
	
	if living_enemies.is_empty():
		emit_signal("last_enemy_killed")
	pass

func is_last_enemy(enemy: Node2D) -> bool:
	return living_enemies.size() == 1 and living_enemies.has(enemy)
