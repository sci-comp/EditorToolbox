@tool
extends EditorPlugin

func execute():
	var selected_paths = get_editor_interface().get_selection().get_selected_files()
	for path in selected_paths:
		print(path)

