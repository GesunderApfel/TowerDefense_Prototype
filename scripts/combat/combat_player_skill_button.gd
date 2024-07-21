class_name PlayerSkillButton
extends Node

@onready var player_skill_button = $"."
@onready var texture_progress_bar = $TextureProgressBar

@export var player_combat_skill : PlayerCombatSkill

var cooldown = 1.0
var cooldown_timer : Timer
var current_cooldown_time

func initialize(playerCombatSkill : PlayerCombatSkill):
	player_combat_skill = playerCombatSkill

func _ready():
	cooldown = player_combat_skill.cooldown
	player_skill_button.texture_pressed = player_combat_skill.texture
	player_skill_button.texture_normal = player_combat_skill.texture

	cooldown_timer = Timer.new()
	self.add_child(cooldown_timer)
	
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(reset_button)
	
	CombatDebug.cooldown_actions.append(self)

func _process(_delta):
	if player_skill_button.disabled == true:
		texture_progress_bar.value = int(cooldown_timer.time_left / cooldown * 100)

func activate_skill():
	player_skill_button.disabled = true
	cooldown_timer.start()

func reset_button():
	player_skill_button.disabled = false
	texture_progress_bar.value = 0

func _on_pressed():
	activate_skill()
