@tool
extends EditorPlugin

func execute():
	
	var selection: EditorSelection = get_editor_interface().get_selection()
	var transform: Transform3D = Transform3D()
	
	transform.origin = Vector3(0, 0, 0)
	transform.basis = Basis()
	
	for selected: Node3D in selection.get_selected_nodes():
		selected.global_transform = transform
		selected.scale = Vector3(1, 1, 1)

