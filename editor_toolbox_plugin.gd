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
	submenu_command.add_item("Show About Window", 1)
	
	# FileSystem
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("FileSystem", submenu_creation)
	submenu_creation.add_item("Create BaseMaterial3D (Ctrl+M)", 0)
	submenu_creation.add_item("Print selected paths (Alt+P)", 1)

	# Scene
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_scene_submenu_item_selected"))
	add_tool_submenu_item("Scene", submenu_creation)
	submenu_creation.add_item("Print selected node names (Alt+N)", 0)
	submenu_creation.add_item("Reset node names (Alt+R)", 1)


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
			
			if event.ctrl_pressed:
				if event.keycode == KEY_M:
					create_base_material_3d()
			
			# Scene
			
			if event.alt_pressed:
				if event.keycode == KEY_N:
					reset_node_name()
				

# ------------------------------------------------------------------------------
# -- Command -------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_command_submenu_item_selected(id: int):
	if id == 0:
		screenshot()
	if id == 1:
		show_about_window()

func screenshot():
	var _instance = preload("res://addons/EditorToolbox/Command/screenshot.gd").new()
	_instance.execute()

func show_about_window():
	reusable_instance = preload("res://addons/EditorToolbox/Command/show_about_window.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

# ------------------------------------------------------------------------------
# -- FileSystem ----------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_creation_submenu_item_selected(id: int):
	if id == 0:
		print_selected_paths()
	if id == 1:
		create_base_material_3d()

func print_selected_paths():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/print_selected_paths.gd").new()
	_instance.execute()

func create_base_material_3d():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/create_base_material_3D.gd").new()
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
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_node_name.gd").new()
	_instance.execute()




# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()

