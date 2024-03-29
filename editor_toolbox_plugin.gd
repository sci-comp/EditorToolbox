@tool
extends EditorPlugin

var file_system_toolbox = load("res://addons/EditorToolbox/editor_toolbox_file_system.gd").new()
var command_toolbox = load("res://addons/EditorToolbox/editor_toolbox_commands.gd").new()

func _enter_tree():	
	add_child(command_toolbox)
	add_child(file_system_toolbox)

func _exit_tree():
	command_toolbox.queue_free()
	file_system_toolbox.queue_free()
