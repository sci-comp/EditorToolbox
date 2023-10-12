@tool
extends EditorPlugin

var submenu_command: PopupMenu
var submenu_creation: PopupMenu
var submenu_test: PopupMenu
var reusable_instance

func _enter_tree():
	
	# Command
	submenu_command = PopupMenu.new()
	submenu_command.connect("id_pressed", Callable(self, "_on_command_submenu_item_selected"))
	add_tool_submenu_item("Command", submenu_command)
	submenu_command.add_item("Screenshot (Ctrl+K)", 0)
	
	# Creation
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("Creation", submenu_creation)
	submenu_creation.add_item("Create BaseMaterial3D", 0)

	# Scene
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_scene_submenu_item_selected"))
	add_tool_submenu_item("Scene", submenu_creation)
	submenu_creation.add_item("Reset node names", 0)
	
	# Test
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_test_submenu_item_selected"))
	add_tool_submenu_item("Test", submenu_creation)
	submenu_creation.add_item("Test0 (Ctrl+0)", 0)
	submenu_creation.add_item("Test1 (Ctrl+9)", 1)

func _exit_tree():
	remove_tool_menu_item("Command")
	remove_tool_menu_item("Creation")
	remove_tool_menu_item("Scene")
	remove_tool_menu_item("Test")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			# Command
			
			if event.ctrl_pressed and event.keycode == KEY_K:
				screenshot()
			
			# Creation
			
			# Scene
			if event.ctrl_pressed:
				if event.keycode == KEY_6:
					reset_node_name()
				
			# Test
			
			if event.ctrl_pressed:
				if event.keycode == KEY_0:
					test0()
				
				elif event.keycode == KEY_9:
					test1()

# ------------------------------------------------------------------------------
# -- Command -------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_command_submenu_item_selected(id: int):
	if id == 0:
		screenshot()

func screenshot():
	var _instance = preload("res://addons/EditorToolbox/screenshot.gd").new()
	_instance.execute()


# ------------------------------------------------------------------------------
# -- Creation ------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_creation_submenu_item_selected(id: int):
	if id == 0:
		create_base_material_3d()

func create_base_material_3d():
	reusable_instance = preload("res://addons/EditorToolbox/CreateBaseMaterial3D.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

# ------------------------------------------------------------------------------
# -- Scene ---------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_scene_submenu_item_selected(id: int):
	if id == 0:
		reset_node_name()

func reset_node_name():
	var _instance = preload("res://addons/EditorToolbox/reset_node_name.gd").new()
	_instance.execute()


# ------------------------------------------------------------------------------
# -- Test ----------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_test_submenu_item_selected(id: int):
	if id == 0:
		test0()
	elif id == 1:
		print("test1 selected")
		test1()

func test0():
	var _instance = preload("res://addons/EditorToolbox/TestPrintNames.gd").new()
	_instance.execute()

func test1():
	reusable_instance = preload("res://addons/EditorToolbox/TestEditorWindow.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()


# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()


