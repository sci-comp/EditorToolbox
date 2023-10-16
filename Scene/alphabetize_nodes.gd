@tool
extends EditorPlugin

func execute():	
	var editor_selection = get_editor_interface().get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()

	for parent_node in selected_nodes:
		print("Alphabetically sorting children of: " + parent_node.name)
		
		var children = parent_node.get_children()
		var names_to_nodes = {}

		for child in children:
			names_to_nodes[child.name] = child

		var sorted_names = names_to_nodes.keys()
		sorted_names.sort()
		
		for i in range(len(sorted_names)):
			var child_name = sorted_names[i]
			var child_node = names_to_nodes[child_name]
			parent_node.move_child(child_node, i)
