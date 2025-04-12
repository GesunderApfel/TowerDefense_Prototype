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
	
func get_playback(animation_tree: AnimationTree):
	if animation_tree.get("parameters/playback") is AnimationNodeStateMachinePlayback:
		return animation_tree.get("parameters/playback")
	else:
		push_error("The animation tree does not have a state machine as root node.")
	pass

