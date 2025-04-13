extends Node

# Why is everywhere the validate_debugger function called?
# Because Godot doesnt give "static" classes private functions
# The method creates a kind of singleton mechanism
# and ensures that the debug UI is created even if functions are called
# which werent intended for global calls

const DEBUG_ACTIVE = true #global control for debug information

const COMBAT_DEBUG_UI = preload("res://scenes/combat/debug/combat_debug_ui.tscn")
var debug_ui

var shortcut_dictionary : Dictionary = {}
var timer_shortcut : Timer


func _ready():
	# creating a timer to stop spamming debug functions
	# when pressing keys
	timer_shortcut = Timer.new()
	timer_shortcut.one_shot = true
	timer_shortcut.wait_time = 1
	self.add_child(timer_shortcut)
	pass

func _process(_delta):
	if not timer_shortcut.is_stopped():
		return
	
	# check if any shortcut for bound debug functions are pressed
	for shortcut in shortcut_dictionary:
		if Input.is_key_pressed(shortcut):
			timer_shortcut.start()
			shortcut_dictionary[shortcut].call()
	pass

## singleton mechanism
func validate_debugger():
	if !DEBUG_ACTIVE:
		return false
		
	if debug_ui == null:
		initialize_combat_debug_ui()
		
	return true

## this function should only be called from within this class
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
var method_binder_buttons
const DEBUG_BUTTON_FOR_METHOD_BINDING = preload("res://scenes/combat/debug/debug_button_for_method_binding.tscn")

## this should only be called by combat_debug_ui to instantiate the UI element
func set_debug_button_binding_container(node):
	if !validate_debugger():
		return 
	method_binder_buttons = node
	pass

## instantiates a debug button
## binds the method to the button and optionally to a key
func bind_debug_method(debug_method: Callable, method_name: String, shortcut = KEY_F30):
	if !validate_debugger():
		return 
	
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(debug_method)
	method_binder_buttons.add_child(button)
	
	# KEY_F30 is just a "magic" key
	if shortcut != KEY_F30:
		method_name += " - " + OS.get_keycode_string(shortcut)
		shortcut_dictionary[shortcut] = debug_method
	
	button.text = method_name
	pass



# ######################################
# ######## Fixed Debug Buttons #########
# These buttons have fixed positions
# They are currently used for player skills 
# ######################################

var fixed_debug_buttons

## this should only be called by combat_debug_ui to instantiate the UI element
func set_fixed_debug_button_binding_container(node):
	if !validate_debugger():
		return 
	
	fixed_debug_buttons = node
	create_fixed_debug_buttons()
	pass

func create_fixed_debug_buttons():
	if !validate_debugger():
		return 
	create_skill_cooldown_reset_button()
	pass

func create_skill_cooldown_reset_button():
	if !validate_debugger():
		return 
	
	var button = DEBUG_BUTTON_FOR_METHOD_BINDING.instantiate()
	button.pressed.connect(cooldown_reset)
	button.text = "Reset Skills Cooldown"
	fixed_debug_buttons.add_child(button)

var cooldown_actions: Array[PlayerSkillButton] = []
func cooldown_reset():
	if !validate_debugger():
		return 
	
	# for all cooldown_actions -> reset
	for action in cooldown_actions:
		action.reset_button()
