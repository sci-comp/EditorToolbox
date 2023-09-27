@tool
extends EditorPlugin

var submenu_command: PopupMenu
var submenu_creation: PopupMenu

func _enter_tree():
	submenu_command = PopupMenu.new()
	submenu_command.connect("id_pressed", Callable(self, "_on_command_submenu_item_selected"))
	add_tool_submenu_item("Command", submenu_command)
	submenu_command.add_item("Screenshot (Ctrl+K)", 0)
	
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("Creation", submenu_creation)
	submenu_creation.add_item("Create BaseMaterial3D", 0)

func _exit_tree():
	remove_tool_menu_item("Command")
	remove_tool_menu_item("Creation")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			if event.ctrl_pressed and event.keycode == KEY_K:
				print("Calling screenshot()")
				screenshot();

func _on_command_submenu_item_selected(id: int):
	if id == 0:
		screenshot()

func _on_creation_submenu_item_selected(id: int):
	if id == 0:
		create_base_material_3d()

func create_base_material_3d():
	var _instance = preload("res://addons/EditorToolbox/CreateBaseMaterial3D.gd").new()
	_instance.execute()

func screenshot():
	var _instance = preload("res://addons/EditorToolbox/Screenshot.gd").new()
	_instance.execute()
