extends Control
@onready var vbc_fixed_debug_buttons = $VBC_FixedDebugButtons

@onready var vbc_method_binder_buttons = $VBC_MethodBinderButtons
# CombatDebug.bind_debug_method(method, method_name) <- thats how you create debug buttons for methods

func _ready():
	CombatDebug.set_debug_button_binding_container(vbc_method_binder_buttons)
	CombatDebug.set_fixed_debug_button_binding_container(vbc_fixed_debug_buttons)
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		pass
	pass
