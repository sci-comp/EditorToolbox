@tool
extends EditorPlugin

func execute():
	var editor = get_editor_interface()
	var editor_selection = editor.get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	var selected_paths = editor.get_selected_paths()
	
	var current_scene = editor.get_edited_scene_root()
	
	if selected_nodes.size() == 1:
		var node = selected_nodes[0]
		
		if selected_paths.size() > 0:
			print("Creating " + str(selected_paths.size()) + " audio sources for: " + node.name)
			
			for path in selected_paths:
				if path.ends_with(".wav"):
					var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
					
					audio_player.name = path.get_file().get_basename()
					audio_player.stream = load(path)
					
					print(path.get_file().get_basename())
					print(audio_player.name)
					
					node.add_child(audio_player)
					audio_player.owner = current_scene
					
					
				
				else:
					print("Selected path is not a wav file: " + str(path))
		else:
			print("Select a sound group in the scene.")
	else:
		print("Only one node in the scene should be selected.")
	
