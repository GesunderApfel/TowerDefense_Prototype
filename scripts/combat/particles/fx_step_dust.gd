extends Node2D

@onready var visuals = $Visuals

func _ready():
	# activate a random smoke particle
	(visuals.get_child(randi_range(0,visuals.get_child_count()-1)) as Node2D) \
	.show()
	pass
