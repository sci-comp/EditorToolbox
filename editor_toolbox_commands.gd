@tool
extends EditorPlugin

var submenu_command: PopupMenu
var reusable_instance

func _enter_tree():
	submenu_command = PopupMenu.new()
	submenu_command.connect("id_pressed", Callable(self, "_on_command_submenu_item_selected"))
	add_tool_submenu_item("Command", submenu_command)
	submenu_command.add_item("Screenshot (Alt+K)", 1)
	submenu_command.add_item("Show about window", 2)

func _exit_tree():
	remove_tool_menu_item("Command")

func _on_command_submenu_item_selected(id: int):
	if id == 2:
		show_about_window()

func show_about_window():
	reusable_instance = preload("res://addons/EditorToolbox/Command/show_about_window.gd").new()
	add_child(reusable_instance)
	reusable_instance.done.connect(_on_reusable_instance_done)
	reusable_instance.execute()

# ------------------------------------------------------------------------------

func _on_reusable_instance_done():
	reusable_instance.queue_free()
