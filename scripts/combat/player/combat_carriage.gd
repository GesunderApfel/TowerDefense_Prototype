extends Node2D

const COMBAT_HEALTH_BAR = preload("res://scenes/combat/combat_health_bar.tscn")
@onready var body2D = $StaticBody2D
@onready var animation_player = $AnimationPlayer
@onready var player_position : Marker2D = $PlayerPosition


# signals
signal got_hit

var health_bar

var maxHealth = 100
var health = 100
var defense = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	CombatDebug.bind_debug_method(heal_completely,"Full Heal Player")
	health_bar = COMBAT_HEALTH_BAR.instantiate()
	health_bar.position = position + Vector2(0, -200)
	get_tree().root.add_child.call_deferred(health_bar)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func heal_completely():
	health = maxHealth
	update_healthbar()

func receive_damage(damage):
	health -= damage
	animation_player.play("shake")
	emit_signal("got_hit")
	update_healthbar()

func update_healthbar():
	health_bar.update_health_value(float(health) / float(maxHealth) * 100)
