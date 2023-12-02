@tool
extends EditorPlugin

func execute():
	var selected_paths = get_editor_interface().get_selected_paths()
	
	var editor = get_editor_interface()
	var file_sys = editor.get_resource_filesystem()
	
	for path in selected_paths:
		
		var file_name = path.get_file()
		var base_name = file_name.get_basename()
		
		var words = file_name.split("_")
		
		for i in range(words.size()):
			words[i] = words[i].capitalize()
			
		var new_file_name = ""
		for word in words:
			new_file_name += word.capitalize() + "_"
		new_file_name = new_file_name.trim_suffix("_")
		
		var new_path = path.replace(file_name, new_file_name)

		var dir_access = DirAccess.open(path.get_base_dir())
		if dir_access.file_exists(file_name):
			
			# Rename
			dir_access.rename(file_name, new_file_name)
			
			# Rename .import
			var import_file = file_name + ".import"
			var new_import_file = new_file_name + ".import"
			if dir_access.file_exists(import_file):
				dir_access.rename(import_file, new_import_file)
			
			print("Renamed " + file_name + " to " + new_file_name)
		else:
			print("File does not exist: " + file_name)
	
	editor.get_resource_filesystem().scan()
