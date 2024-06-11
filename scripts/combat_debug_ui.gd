extends Control

@onready var vbc_method_binder_buttons = $VBC_MethodBinderButtons


func _ready():
	CombatDebug.set_debug_button_binding_container(vbc_method_binder_buttons)
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		CombatDebug.bind_debug_method(test, "test")


func test():
	print("HEY")
