extends Node2D

const COMBAT_PLAYER = preload("res://scenes/combat/combat_test/combat_player.tscn")
const COMBAT_UI = preload("res://scenes/combat/combat_ui.tscn")

const ALLY = preload("res://scenes/combat/combat_test/ally.tscn")


var player
var carriage_player_placement_point : Marker2D
@onready var carriage = $Carriage

# Called when the node enters the scene tree for the first time.
func _ready():
	CombatDebug.bind_debug_method(spawn_ally, "Spawn Ally", KEY_2)
	
	var combatUI = COMBAT_UI.instantiate()
	get_tree().root.add_child.call_deferred(combatUI)
	
	carriage_player_placement_point = carriage.player_position
	player = COMBAT_PLAYER.instantiate()
	player.global_position = carriage_player_placement_point.global_position
	
	self.add_child(player)
	
	
	pass # Replace with function body.

func spawn_ally():
	var ally = ALLY.instantiate()
	var spawning_left : bool = randi_range(0,1)
	var spawning_direction : float = 1 if spawning_left else -1
	
	ally.global_position = carriage.global_position \
	+ Vector2(800.0 * spawning_direction, 0)
	ally.is_looking_left = spawning_left
	ally.carriage = carriage
	# TODO: ground height must be set in this class
	self.add_child(ally)
