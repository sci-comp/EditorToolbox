@tool
extends EditorPlugin

var submenu_command: PopupMenu
var reusable_instance

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed() and !event.is_echo():
			if event.alt_pressed: 
				if event.keycode == KEY_U:
					create_sound_group()

func _enter_tree():
	submenu_command = PopupMenu.new()
	submenu_command.connect("id_pressed", Callable(self, "_on_command_submenu_item_selected"))
	add_tool_submenu_item("EditorToolbox/Command", submenu_command)
	submenu_command.add_item("Create sound groups", 0)
	submenu_command.add_item("Screenshot (Alt+K)", 1)
	submenu_command.add_item("Show about window", 2)

func _exit_tree():
	remove_tool_menu_item("Command")

func _on_command_submenu_item_selected(id: int):
	if id == 0:
		create_sound_group()
	if id == 2:
		show_about_window()

func create_sound_group():
	var _instance = preload("res://addons/EditorToolbox/Command/create_sound_group.gd").new()
	_instance.execute()

func show_about_window():
	reusable_instance = preload("res://addons/EditorToolbox/Command/show_about_window.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	reusable_instance.queue_free()
