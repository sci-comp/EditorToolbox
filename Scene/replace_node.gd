@tool
extends EditorPlugin

func execute():
	"""
	Replaces each selected node in the Scene with an instance of the selected PackedScene from the FileSystem.
	The instantiated PackedScene inherits the transform of the node it replaces. The function verifies that exactly
	one PackedScene is selected in the FileSystem and at least one node is selected in the Scene.
	"""
	
	var editor = get_editor_interface()
	var selected_paths = editor.get_selected_paths()
	var selected_nodes = editor.get_selection().get_selected_nodes()

	# Check for exact one selected PackedScene path
	if selected_paths.size() != 1:
		print("Error: Please select exactly one PackedScene in the FileSystem.")
		return

	var selected_path = selected_paths[0]
	var resource = load(selected_path)
	if not resource or not resource is PackedScene:
		print("Error: The selected path is not a valid PackedScene.")
		return
	
	# Check for selection in the Scene
	if selected_nodes.is_empty():
		print("Error: Select at least one node in the Scene.")
		return

	# Replace each selected node with an instance of the selected PackedScene
	for node in selected_nodes:
		var instance = resource.instantiate()
		instance.transform = node.transform
		print(node.get_owner())
		
		var parent = node.get_parent()
		if parent:
			parent.add_child(instance)
			instance.owner = get_editor_interface().get_edited_scene_root()
		
			instance.name = get_unique_name(instance.name, parent)
		
		node.queue_free()
		
		# TODO: Notify that the scene has been altered.

func get_unique_name(base_name: String, parent: Node) -> String:
	var new_name = base_name
	var count = 1
	var ends_with_digit = base_name.match(".*\\d+$")
	
	var regex = RegEx.new()
	regex.compile("^(.*?)(\\d+)$")
	
	while parent.has_node(new_name):
		
		if ends_with_digit:
			var result = regex.search(new_name)
			
			if result:
				print(new_name)
				var name_part = result.get_string(1)
				var num_part = int(result.get_string(2))
				print(name_part)
				print(num_part)
				new_name = name_part + str(num_part + count)
				
			else:
				new_name = base_name + str(count)
		else:
			new_name = base_name + str(count)
			
		count += 1
	
	return new_name
	
