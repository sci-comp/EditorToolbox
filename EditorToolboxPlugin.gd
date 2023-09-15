@tool
extends EditorPlugin

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			if event.ctrl_pressed and event.alt_pressed and event.keycode == KEY_T:
				print_test_message()
				get_viewport().set_input_as_handled()

func _enter_tree():
	add_tool_menu_item("Create BaseMaterial3D", Callable(self, "create_base_material_3d"))
	add_tool_menu_item("Print Test (Ctrl+Alt+T)", Callable(self, "print_test_message"))
	
func _exit_tree():
	remove_tool_menu_item("Create BaseMaterial3D")
	remove_tool_menu_item("Print Test (Ctrl+Alt+T)")

func print_test_message():
	print("Test message from plugin.")

func create_base_material_3d():
	var create_base_material = preload("res://addons/EditorToolbox/CreateBaseMaterial3D.gd").new()
	create_base_material.execute()
