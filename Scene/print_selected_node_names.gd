@tool
extends EditorPlugin

func execute():
	var selection = get_editor_interface().get_selection()
	for selected in selection:
		print(selected)

