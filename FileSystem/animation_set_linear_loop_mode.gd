@tool
extends EditorPlugin

signal done

var editor_utilities = preload("res://addons/EditorToolbox/editor_toolbox_utilities.gd").new()

func execute():
	var selected_paths = get_editor_interface().get_selected_paths()

	for path in selected_paths:
		print("path: " + path)
		
		var file_name = path.get_file()
		var base_name = file_name.get_basename()

		if base_name == "":
			print("Returning early. File name: " + file_name)
			continue

		var resource = load(path)
		
		if resource is Animation:
			print("Setting loop mode to linear for: " + resource.resource_name)
			var animation = resource
			animation.loop_mode = Animation.LOOP_LINEAR
		else:
			print("Resource is not an animation: " + resource.name)

