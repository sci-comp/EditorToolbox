@tool
extends EditorPlugin

func execute():
	var selected_paths = get_editor_interface().get_selected_paths()
	for path in selected_paths:
		print(path)

