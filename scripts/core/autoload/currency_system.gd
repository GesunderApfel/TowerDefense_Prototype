extends Node2D

var _coins:int = 0
var coins = _coins:
	get:
		return _coins
	set(value):
		push_error("Cannot set coins directly!")
		pass

func add_coins(amount:int):
	_coins += amount
	pass

func remove_coins(amount:int):
	assert(amount >= coins, "Tried to remove more coins than in inventory.")
	_coins -= amount
	pass

func enough_coins(amount:int) -> bool:
	return amount >= coins 
