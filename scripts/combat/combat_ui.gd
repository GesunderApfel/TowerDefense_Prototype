extends Control


@onready var skills_container = $SkillsContainer
const PLAYER_SKILL_BUTTON_BASE = preload("res://scenes/combat/player_skill_button_base.tscn")

const PLAYER_SKILL_REPAIR = preload("res://resources/combat/player_skills/player_skill_repair.tres")
const PLAYER_SKILL_I_AM_DEATH = preload("res://resources/combat/player_skills/player_skill_i_am_death.tres")

func _ready():
	var skill_repair = PLAYER_SKILL_BUTTON_BASE.instantiate()
	skill_repair.initialize(PLAYER_SKILL_REPAIR)
	
	var skill_kill_everything = PLAYER_SKILL_BUTTON_BASE.instantiate()
	skill_kill_everything.initialize(PLAYER_SKILL_I_AM_DEATH)
	
	skills_container.add_child(skill_repair)
	skills_container.add_child(skill_kill_everything)
	pass
