@tool
extends EditorPlugin

var submenu_command: PopupMenu
var submenu_file_system: PopupMenu
var submenu_test: PopupMenu
var reusable_instance

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			if event.alt_pressed:
				if event.keycode == KEY_L:
					instantiate_in_a_row(1)
				if event.keycode == KEY_SEMICOLON:
					instantiate_in_a_row(2)
				if event.keycode == KEY_APOSTROPHE:
					instantiate_in_a_row(5)
				if event.keycode == KEY_M:
					create_base_material_3d()

func _enter_tree():
	submenu_file_system = PopupMenu.new()
	submenu_file_system.connect("id_pressed", Callable(self, "_on_creation_submenu_item_selected"))
	add_tool_submenu_item("FileSystem", submenu_file_system)
	
	submenu_file_system.add_item("Animation: Set Linear Loop", 0)
	submenu_file_system.add_item("Create BaseMaterial3D (Ctrl+M)", 1)
	
	submenu_file_system.add_item("Layout, 1 unit (Alt+L)", 20)
	submenu_file_system.add_item("Layout, 2 units (Alt+;)", 21)
	submenu_file_system.add_item("Layout, 5 units (Alt+')", 22)
	
	submenu_file_system.add_item("Reimport all glb", 99)

func _exit_tree():
	remove_tool_menu_item("FileSystem")

func _on_creation_submenu_item_selected(id: int):
	
	if id == 0:
		animation_set_linear_loop_mode()
	if id == 1:
		create_base_material_3d()
	if id == 20:
		instantiate_in_a_row(1)
	if id == 21:
		instantiate_in_a_row(2)
	if id == 22:
		instantiate_in_a_row(5)
	if id == 4:
		reimport_all_glb()

func animation_set_linear_loop_mode():
	var _instance = preload("res://addons/EditorToolbox/FileSystem/animation_set_linear_loop_mode.gd").new()
	_instance.execute()

func create_base_material_3d():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/create_base_material_3D.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func instantiate_in_a_row(_space):
	var _instance = preload("res://addons/EditorToolbox/FileSystem/instantiate_in_a_row.gd").new()
	_instance.execute(_space)

func reimport_all_glb():
	reusable_instance = preload("res://addons/EditorToolbox/FileSystem/reimport_all_glb.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()



