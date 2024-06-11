extends Node

func _ready():
	pass

func _process(delta):
	#if vbc_method_binder_buttons != null:
		#print("hey")
	#else: 
		#print("null")
	pass



#######################################
########### DEBUG CALLBACKS ###########
#######################################
var vbc_method_binder_buttons
const DEBUG_BUTTON_FOR_METHOD_BINDING = preload("res://scenes/combat/debug/debug_button_for_method_binding.tscn")

# this should only be called by the debug ui to instantiate the UI element
func set_debug_button_binding_container(node):
	vbc_method_binder_buttons = node

func bind_debug_method(debug_method: Callable, method_name: String):
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(debug_method)
	button.text = method_name
	vbc_method_binder_buttons.add_child(button)
	pass


