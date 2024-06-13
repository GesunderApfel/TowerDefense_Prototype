class_name PlayerCombatSkill
extends Resource

@export var name = "DefaultSkillName"
@export var texture : CompressedTexture2D = preload("res://assets/graphics/combat/ui/PlayerSkillPlacerholder.png")
@export var cooldown = 5.0

func activate_skill():
	#behaviour is defined in child resource
	pass
