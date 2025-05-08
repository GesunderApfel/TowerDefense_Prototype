extends Node2D

signal coins_changed

var _coins:int = 0
var coins = _coins:
	get:
		return _coins
	set(value):
		push_error("Cannot set coins directly!")
		pass

func add_coins(amount:int):
	_coins += amount
	coins_changed.emit()
	pass

func remove_coins(amount:int):
	assert(amount >= coins, "Tried to remove more coins than in inventory.")
	_coins -= amount
	coins_changed.emit()
	pass

func enough_coins(amount:int) -> bool:
	return amount >= coins 
