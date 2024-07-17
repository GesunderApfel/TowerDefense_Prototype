extends Node

const DEBUG_ACTIVE = true #global control for debug

const COMBAT_DEBUG_UI = preload("res://scenes/combat/debug/combat_debug_ui.tscn")
var debug_ui


func _ready():
	#this should pretty much never be called
	pass

func _process(delta):
	#if vbc_method_binder_buttons != null:
		#print("hey")
	#else: 
		#print("null")
	pass

func initialize_combat_debug_ui():
	print("Combat Debug UI - IsActive: {isActive}".format({"isActive": DEBUG_ACTIVE}))	
	
	if !DEBUG_ACTIVE:
		pass
	
	if debug_ui != null:
		pass
	else:
		debug_ui = COMBAT_DEBUG_UI.instantiate()
		add_child(debug_ui)
		pass

#######################################
########### DEBUG CALLBACKS ###########
#######################################
var vbc_method_binder_buttons
const DEBUG_BUTTON_FOR_METHOD_BINDING = preload("res://scenes/combat/debug/debug_button_for_method_binding.tscn")

# this should only be called by combat_debug_ui to instantiate the UI element
func set_debug_button_binding_container(node):
	if !DEBUG_ACTIVE:
		pass 
	vbc_method_binder_buttons = node
	

func bind_debug_method(debug_method: Callable, method_name: String):
	if !DEBUG_ACTIVE:
		pass 
	
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
	if !DEBUG_ACTIVE:
		pass 
	
	vbc_fixed_debug_buttons = node
	create_fixed_debug_buttons()
	
func create_fixed_debug_buttons():
	if !DEBUG_ACTIVE:
		pass 
	create_skill_cooldown_reset_button()

func create_skill_cooldown_reset_button():
	if !DEBUG_ACTIVE:
		pass 
	
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(cooldown_reset)
	button.text = "Reset Skills Cooldown"
	vbc_fixed_debug_buttons.add_child(button)

var cooldown_actions: Array[PlayerSkillButton] = []
func cooldown_reset():
	if !DEBUG_ACTIVE:
		pass 
	
	# for all cooldown_actions -> reset
	for action in cooldown_actions:
		action.reset_button()
	pass
