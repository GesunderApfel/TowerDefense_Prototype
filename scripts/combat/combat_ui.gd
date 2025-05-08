extends Control


@onready var skills_container = $SkillsContainer
const PLAYER_SKILL_BUTTON_BASE = preload("res://scenes/combat/player_skill_button_base.tscn")

const PLAYER_SKILL_REPAIR = preload("res://resources/combat/player_skills/player_skill_repair.tres")
const PLAYER_SKILL_I_AM_DEATH = preload("res://resources/combat/player_skills/player_skill_i_am_death.tres")

@onready var coins_label = $CanvasLayer/CoinContainer/CoinsLabel

func _ready():
	update_coins()
	CurrencySystem.coins_changed.connect(update_coins)
	
	init_combat_debug()
	pass

func update_coins():
	coins_label.text = str(CurrencySystem.coins)
	pass

func init_combat_debug():
	CombatDebug.initialize_combat_debug_ui()
	
	var skill_repair = PLAYER_SKILL_BUTTON_BASE.instantiate()
	skill_repair.initialize(PLAYER_SKILL_REPAIR)
	
	var skill_kill_everything = PLAYER_SKILL_BUTTON_BASE.instantiate()
	skill_kill_everything.initialize(PLAYER_SKILL_I_AM_DEATH)
	
	skills_container.add_child(skill_repair)
	skills_container.add_child(skill_kill_everything)
	pass
