@tool
class_name EnemySpawnWave extends Node

func _process(_delta):
	if Engine.is_editor_hint():
		var children = get_children()
		var sum : float = 0
		var percentage_dict : Dictionary = {}
		var child_dict : Dictionary = {}
		for c in children:
			sum += c.percentage
			percentage_dict[c.name] = c.percentage
			child_dict[c.name] = c
		

		for enemy_name in percentage_dict.keys():
			var actual_percentage:float = \
				child_dict[enemy_name].percentage / sum *100.0
			
			child_dict[enemy_name].percentage = actual_percentage
			var correct_name = \
			UtilityEnemy.EnemyName.keys()[child_dict[enemy_name].enemy_name] \
				+ "_" + str(actual_percentage).substr(0,4)
				
			child_dict[enemy_name].name=correct_name

var enemies: Array
func spawn_enemy() -> Node:
	var index = 0
	# TODO: should return enemy path to BanditSpawner, so the spawner can
	# actually instantiate the node
	return enemies[index]
	
	
