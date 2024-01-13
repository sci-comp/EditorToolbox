@tool
extends EditorPlugin

var submenu_scene: PopupMenu
var reusable_instance

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			if event.ctrl_pressed and event.alt_pressed:
				if event.keycode == KEY_N:
					print_selected_node_names()
		
			elif event.ctrl_pressed:
				print("none")
			
			elif event.alt_pressed:
				if event.keycode == KEY_A:
					alphabetize_nodes()
				elif event.keycode == KEY_R:
					reset_node_name()
				elif event.keycode == KEY_T:
					reset_transform()

func manual_enter_tree():
	submenu_scene = PopupMenu.new()
	submenu_scene.connect("id_pressed", Callable(self, "_on_scene_submenu_item_selected"))
	add_tool_submenu_item("Scene", submenu_scene)
	
	submenu_scene.add_item("Alphabetize children of selected nodes (Alt+A)", 0)
	submenu_scene.add_item("Reset position (Alt+E)", 1)
	submenu_scene.add_item("Reset rotation (Alt+R)", 2)
	submenu_scene.add_item("Reset transform (Alt+T)", 3)
	
	submenu_scene.add_item("Reset node names (Ctrl+Alt+N)", 5)
	submenu_scene.add_item("Swap node (Alt+S)", 3)
	
	submenu_scene.add_item("Add prefix", 0)
	submenu_scene.add_item("Print selected node names", 2)

func manual_exit_tree():
	remove_tool_menu_item("Scene")

func _on_scene_submenu_item_selected(id: int):
	if id == 0:
		add_prefix_to_selected_in_scene()
	if id == 1:
		alphabetize_nodes()
	if id == 2:
		print_selected_node_names()
	if id == 3:
		replace_node()
	if id == 4:
		reset_node_name()
	if id == 5:
		reset_transform()

func add_prefix_to_selected_in_scene():
	reusable_instance = preload("res://addons/EditorToolbox/Scene/add_prefix_to_selected_in_scene.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

func alphabetize_nodes():
	var _instance = preload("res://addons/EditorToolbox/Scene/alphabetize_nodes.gd").new()
	_instance.execute()

func print_selected_node_names():
	var _instance = preload("res://addons/EditorToolbox/Scene/print_selected_node_names.gd").new()
	_instance.execute()

func replace_node():
	var _instance = preload("res://addons/EditorToolbox/Scene/replace_node.gd").new()
	_instance.execute()

func reset_node_name():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_node_name.gd").new()
	_instance.execute()

func reset_transform():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_transform.gd").new()
	_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()

