extends Node2D

@onready var body2D = $StaticBody2D

var maxHealth = 10
var health = 10
var defense = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	CombatDebug.bind_debug_method(heal_completely,"Full Heal Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#########################
######### DEBUG #########
#########################

func heal_completely():
	health = maxHealth
