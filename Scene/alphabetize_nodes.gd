@tool
extends EditorPlugin

func execute():	
	var editor_selection = get_editor_interface().get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()

	for parent_node in selected_nodes:
		print("Alphabetically sorting children of: " + parent_node.name)
		
		var children = parent_node.get_children()
		
		var names_to_nodes = {}
		var names_to_node3ds = {}

		for child in children:
			if (child is Node3D):
				names_to_node3ds[child.name] = child
			else:
				names_to_nodes[child.name] = child
		
		var sorted_node_names = names_to_nodes.keys()
		var sorted_node3d_names = names_to_node3ds.keys()
		
		sorted_node_names.sort()
		sorted_node3d_names.sort()
		
		sorted_node_names.append(sorted_node3d_names)
		var sorted_names = sorted_node_names;
		
		for i in range(len(sorted_names)):
			var child_name = sorted_names[i]
			var child_node = names_to_nodes[child_name]
			parent_node.move_child(child_node, i)
