class_name PlayerCombatSkill_KillEverythingOnScreen
extends PlayerCombatSkill

func activate_skill():
	print("Player Skill: I am Death.")
	for e in WaveManager.living_enemies:
		assert(e.has_method("receive_damage"), "Enemy %e is missing method 'receive_damage'" % e.name)
		e.receive_damage(10000000)
	pass
