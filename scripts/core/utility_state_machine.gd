extends Node


func create_timer_for_animation(self_reference: Node,
	animation_tree: AnimationTree,
	dictionary: Dictionary,
	animation_name: String,):
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = animation_tree.get_animation(animation_name).length
	self_reference.add_child(timer)
	dictionary[animation_name] = timer
	pass
