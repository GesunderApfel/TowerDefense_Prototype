extends Node


func _ready():
	pass

func _process(delta):
	pass




#######################################
########### DEBUG CALLBACKS ###########
#######################################
var debug_method_dict = {}


func bind_debug_method(debug_method: Callable, method_name: String):
	debug_method_dict[method_name] = debug_method
	
	var binding_method = call_debug_method(method_name)
	# spawn UI element with name 
	# bind UI element to debug method dictionary
	pass

func call_debug_method(method_name: String):
	debug_method_dict[method_name].Call()
