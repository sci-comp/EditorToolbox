@tool
extends EditorPlugin

var submenu_command: PopupMenu
var submenu_file_system: PopupMenu
var submenu_test: PopupMenu
var reusable_instance

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			if event.ctrl_pressed and event.alt_pressed:
				if event.keycode == KEY_P:
					print_selected_paths()
					
			elif event.ctrl_pressed:
				if event.keycode == KEY_1:
					instantiate_in_a_row()
				if event.keycode == KEY_M:
					create_base_material_3d()
				
				

func manual_enter_tree():
	submenu_file_system = PopupMenu.new()
	submenu_file_system.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("FileSystem", submenu_file_system)
	submenu_file_system.add_item("Animation: Set Linear Loop", 0)
	submenu_file_system.add_item("Capitalize selected paths", 1)
	submenu_file_system.add_item("Create BaseMaterial3D (Ctrl+M)", 2)
	submenu_file_system.add_item("Instantiate in a row (Alt+1)", 3)
	submenu_file_system.add_item("Print selected paths (Ctrl+Alt+P)", 4)
	submenu_file_system.add_item("Reimport all glb", 5)
	submenu_file_system.add_item("To upper for prefixes of selected paths", 6)

func manual_exit_tree():
	remove_tool_menu_item("FileSystem")
	remove_tool_menu_item("Scene")
	remove_tool_menu_item("Test")

func _on_creation_submenu_item_selected(id: int):
	
	if id == 0:
		animation_set_linear_loop_mode()
	if id == 1:
		capitalize_selected_paths()
	if id == 2:
		create_base_material_3d()
	if id == 3:
		instantiate_in_a_row()
	if id == 4:
		print_selected_paths()
	if id == 5:
		reimport_all_glb()
	if id == 6:
		to_upper_for_prefixes_of_selected_paths()

func animation_set_linear_loop_mode():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/animation_set_linear_loop_mode.gd").new()
	_instance.execute()

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

func reimport_all_glb():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/reimport_all_glb.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func to_upper_for_prefixes_of_selected_paths():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/to_upper_for_prefixes_of_selected_paths.gd").new()
	_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()

