extends Node2D

@onready var carriage = $Carriage
const COMBAT_PLAYER = preload("res://scenes/combat/combat_test/combat_player.tscn")

var carriage_player_placement_point : Marker2D

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	carriage_player_placement_point = carriage.player_position
	player = COMBAT_PLAYER.instantiate()	
	player.global_position = carriage_player_placement_point.global_position
	
	self.add_child(player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
