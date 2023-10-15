@tool
extends EditorPlugin

func execute():
	var editor_selection = get_editor_interface().get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	
	for selected_node in selected_nodes:
		print(selected_node.name)

