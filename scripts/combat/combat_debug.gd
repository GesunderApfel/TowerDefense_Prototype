extends Node

const DEBUG_ACTIVE = true #global control for debug

const COMBAT_DEBUG_UI = preload("res://scenes/combat/debug/combat_debug_ui.tscn")
var debug_ui

var shortcut_dictionary : Dictionary = {}
var timer_shortcut : Timer


func _ready():
	timer_shortcut = Timer.new()
	timer_shortcut.one_shot = true
	timer_shortcut.wait_time = 1
	self.add_child(timer_shortcut)
	pass

func _process(_delta):
	if not timer_shortcut.is_stopped():
		return
	
	for shortcut in shortcut_dictionary:
		if Input.is_key_pressed(shortcut):
			timer_shortcut.start()
			shortcut_dictionary[shortcut].call()
	pass

func validate_debugger():
	if !DEBUG_ACTIVE:
		return false
		
	if debug_ui == null:
		initialize_combat_debug_ui()
		
	return true

func initialize_combat_debug_ui():
	print("Combat Debug UI - IsActive: {isActive}".format({"isActive": DEBUG_ACTIVE}))	
	
	if !DEBUG_ACTIVE:
		return
	
	if debug_ui != null:
		return
	else:
		debug_ui = COMBAT_DEBUG_UI.instantiate()
		add_child(debug_ui)
		return

#######################################
########### DEBUG CALLBACKS ###########
#######################################
var vbc_method_binder_buttons
const DEBUG_BUTTON_FOR_METHOD_BINDING = preload("res://scenes/combat/debug/debug_button_for_method_binding.tscn")

# this should only be called by combat_debug_ui to instantiate the UI element
func set_debug_button_binding_container(node):
	if !validate_debugger():
		return 
	vbc_method_binder_buttons = node
	

func bind_debug_method(debug_method: Callable, method_name: String, shortcut = KEY_F30):
	if !validate_debugger():
		return 
	
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(debug_method)
	vbc_method_binder_buttons.add_child(button)
	
	#KEY_F30 is just a magic key
	if shortcut != KEY_F30:
		method_name += " - " + OS.get_keycode_string(shortcut)
		shortcut_dictionary[shortcut] = debug_method
	
	button.text = method_name



#######################################
######### Fixed Debug Buttons #########
#######################################

var vbc_fixed_debug_buttons

# this should only be called by combat_debug_ui to instantiate the UI element
func set_fixed_debug_button_binding_container(node):
	if !validate_debugger():
		return 
	
	vbc_fixed_debug_buttons = node
	create_fixed_debug_buttons()
	
func create_fixed_debug_buttons():
	if !validate_debugger():
		return 
	create_skill_cooldown_reset_button()

func create_skill_cooldown_reset_button():
	if !validate_debugger():
		return 
	
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(cooldown_reset)
	button.text = "Reset Skills Cooldown"
	vbc_fixed_debug_buttons.add_child(button)

var cooldown_actions: Array[PlayerSkillButton] = []
func cooldown_reset():
	if !validate_debugger():
		return 
	
	# for all cooldown_actions -> reset
	for action in cooldown_actions:
		action.reset_button()
