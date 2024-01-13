@tool
extends EditorPlugin

var submenu_scene: PopupMenu
var reusable_instance

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			
			if event.alt_pressed:
				if event.keycode == KEY_A:
					alphabetize_nodes()
				elif event.keycode == KEY_N:
					reset_node_name()
				elif event.keycode == KEY_R:
					reset_transform()
				elif event.keycode == KEY_T:
					swap_node()

func _enter_tree():
	
	submenu_scene = PopupMenu.new()
	submenu_scene.connect("id_pressed", Callable(self, "_on_scene_submenu_item_selected"))
	add_tool_submenu_item("Scene", submenu_scene)
	
	submenu_scene.add_item("Alphabetize nodes (Alt+A)", 0)
	submenu_scene.add_item("Reset node names (Alt+N)", 1)
	submenu_scene.add_item("Reset transform (Alt+T)", 3)
	submenu_scene.add_item("Swap node (Alt+S)", 4)

func _exit_tree():
	remove_tool_menu_item("Scene")

func _on_scene_submenu_item_selected(id: int):
	if id == 0:
		alphabetize_nodes()
	if id == 1:
		reset_node_name()
	if id == 2:
		reset_transform()
	if id == 3:
		swap_node()

func alphabetize_nodes():
	var _instance = preload("res://addons/EditorToolbox/Scene/alphabetize_nodes.gd").new()
	_instance.execute()

func reset_node_name():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_node_name.gd").new()
	_instance.execute()

func reset_transform():
	var _instance = preload("res://addons/EditorToolbox/Scene/reset_transform.gd").new()
	_instance.execute()
	
func swap_node():
	var _instance = preload("res://addons/EditorToolbox/Scene/swap_node.gd").new()
	_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	print("Freeing instance")
	reusable_instance.queue_free()
