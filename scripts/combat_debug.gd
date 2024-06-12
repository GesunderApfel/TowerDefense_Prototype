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

# this should only be called by combat_debug_ui to instantiate the UI element
func set_debug_button_binding_container(node):
	vbc_method_binder_buttons = node
	

func bind_debug_method(debug_method: Callable, method_name: String):
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(debug_method)
	button.text = method_name
	vbc_method_binder_buttons.add_child(button)


#######################################
######### Fixed Debug Buttons #########
#######################################

var vbc_fixed_debug_buttons

# this should only be called by combat_debug_ui to instantiate the UI element
func set_fixed_debug_button_binding_container(node):
	vbc_fixed_debug_buttons = node
	
func create_fixed_debug_buttons():
	create_skill_cooldown_reset_button()

func create_skill_cooldown_reset_button():
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(cooldown_reset)
	button.text = "Reset Skills Cooldown"
	vbc_fixed_debug_buttons.add_child(button)

var cooldown_actions = [PlayerSkill]
func cooldown_reset():
	# for all cooldown_actions -> reset
	for action in cooldown_actions:
		pass
	pass
