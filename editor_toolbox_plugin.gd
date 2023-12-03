@tool
extends EditorPlugin

var submenu_command: PopupMenu
var submenu_creation: PopupMenu
var submenu_test: PopupMenu
var reusable_instance

func _enter_tree():
	
	# -----------------------------------------------------------------
	# -- Command ------------------------------------------------------
	# -----------------------------------------------------------------
	
	submenu_command = PopupMenu.new()
	submenu_command.connect("id_pressed", Callable(self, "_on_command_submenu_item_selected"))
	add_tool_submenu_item("Command", submenu_command)
	submenu_command.add_item("Screenshot (Ctrl+K)", 0)
	submenu_command.add_item("Show About Window", 1)
	
	# -----------------------------------------------------------------
	# -- FileSystem ---------------------------------------------------
	# -----------------------------------------------------------------
	
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("FileSystem", submenu_creation)
	submenu_creation.add_item("Capitalize selected paths", 0)
	submenu_creation.add_item("Create BaseMaterial3D (Ctrl+M)", 1)
	submenu_creation.add_item("Instantiate in a row (Ctrl+1)", 2)
	submenu_creation.add_item("Print selected paths (Alt+P)", 3)
	submenu_creation.add_item("Reimport glb (Ctrl+Alt+I)", 4)
	submenu_creation.add_item("Replace term", 5)
	submenu_creation.add_item("To upper for prefixes of selected paths", 6)
	

	# -----------------------------------------------------------------
	# -- Scene --------------------------------------------------------
	# -----------------------------------------------------------------
	
	submenu_creation = PopupMenu.new()
	submenu_creation.connect("id_pressed", Callable(self, "_on_scene_submenu_item_selected"))
	add_tool_submenu_item("Scene", submenu_creation)
	submenu_creation.add_item("Alphabetize children of selected nodes (Alt+A)", 0)
	submenu_creation.add_item("Print selected node names (Alt+N)", 1)
	submenu_creation.add_item("Reset node names (Alt+R)", 2)
	submenu_creation.add_item("Reset transform (Ctrl+T)", 3)
	submenu_creation.add_item("Replace node", 4)

func _exit_tree():
	remove_tool_menu_item("Command")
	remove_tool_menu_item("Creation")
	remove_tool_menu_item("Scene")
	remove_tool_menu_item("Test")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			# -----------------------------------------------------------------
			# -- Command ------------------------------------------------------
			# -----------------------------------------------------------------
			
			if event.ctrl_pressed: 
				if event.keycode == KEY_K:
					screenshot()
			
			# -----------------------------------------------------------------
			# -- FileSystem ---------------------------------------------------
			# -----------------------------------------------------------------
			
			if event.ctrl_pressed and event.alt_pressed:
				if event.keycode == KEY_I:
					reimport_glb()
					
			elif event.ctrl_pressed:
				if event.keycode == KEY_1:
					instantiate_in_a_row()
				if event.keycode == KEY_M:
					create_base_material_3d()
					
			elif event.alt_pressed:
				if event.keycode == KEY_P:
					print_selected_paths()
			
			# -----------------------------------------------------------------
			# -- Scene --------------------------------------------------------
			# -----------------------------------------------------------------
			
			if event.ctrl_pressed and event.alt_pressed:
				print("temp")
			
			elif event.ctrl_pressed:
				if event.keycode == KEY_T:
					reset_transform()
			
			elif event.alt_pressed:
				if event.keycode == KEY_A:
					alphabetize_nodes()
				elif event.keycode == KEY_N:
					print_selected_node_names()
				elif event.keycode == KEY_R:
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
		capitalize_selected_paths()
	if id == 1:
		create_base_material_3d()
	if id == 2:
		instantiate_in_a_row()
	if id == 3:
		print_selected_paths()
	if id == 4:
		reimport_glb()
	if id == 5:
		replace_term()
	if id == 6:
		to_upper_for_prefixes_of_selected_paths()

func capitalize_selected_paths():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/capitalize_selected_paths.gd").new()
	_instance.execute()

func create_base_material_3d():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/create_base_material_3D.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func instantiate_in_a_row():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/instantiate_in_a_row.gd").new()
	_instance.execute()

func print_selected_paths():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/print_selected_paths.gd").new()
	_instance.execute()

func replace_term():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/replace_term.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func reimport_glb():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/reimport_glb.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func to_upper_for_prefixes_of_selected_paths():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/to_upper_for_prefixes_of_selected_paths.gd").new()
	_instance.execute()

# ------------------------------------------------------------------------------
# -- Scene ---------------------------------------------------------------------
# ------------------------------------------------------------------------------

func _on_scene_submenu_item_selected(id: int):
	if id == 0:
		alphabetize_nodes
	if id == 1:
		print_selected_node_names()
	if id == 2:
		reset_node_name()
	if id == 3:
		reset_transform()
	if id == 4:
		replace_node()

func alphabetize_nodes():
	var _instance = preload("res://addons/EditorToolbox/Scene/alphabetize_nodes.gd").new()
	_instance.execute()

func print_selected_node_names():
	var _instance = preload("res://addons/EditorToolbox/Scene/print_selected_node_names.gd").new()
	_instance.execute()

func reset_node_name():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_node_name.gd").new()
	_instance.execute()

func reset_transform():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_transform.gd").new()
	_instance.execute()

func replace_node():
	var _instance = preload("res://addons/EditorToolbox/Scene/replace_node.gd").new()
	_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()


