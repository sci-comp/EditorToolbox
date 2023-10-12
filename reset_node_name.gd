@tool
extends EditorPlugin

func execute():
	var editor_selection = get_editor_interface().get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()

	for node in selected_nodes:
		if node.scene_file_path:
			var scene_name = node.scene_file_path.get_file().get_basename()
			node.name = scene_name
		else:
			print("Passing over: " + node.name)

