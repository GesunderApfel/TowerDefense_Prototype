extends Node

func _ready():
	print("DEBUG_HELPER ACTIVE")
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" is ESC per default
		get_tree().paused = not get_tree().paused
	pass
