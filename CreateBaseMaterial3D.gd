@tool
extends Object

# <summary>
# Searches for texture files in "res://Temp" and creates StandardMaterial3D 
# resources for them. If a corresponding normal map exists, it is also added 
# to the material. The created materials are saved in the same "res://Temp" 
# directory.
# </summary>

func execute():
	var dir = DirAccess.open("res://Temp")
	dir.list_dir_begin()
	var texture_files = []
	var normal_maps = []
	var normal_suffix = "_n.png"
	
	while true:
		var filename = dir.get_next()
		
		if filename == "":
			break
			
		if filename.ends_with(".import"):
			continue
			
		if filename.begins_with("T_"):
			texture_files.append(filename)
			
			if filename.ends_with(normal_suffix):
				normal_maps.append(filename)
	
	for filename in texture_files:
		
		if filename in normal_maps:
			continue
		
		var base_name = filename.get_basename()
		var mat = StandardMaterial3D.new()
		var albedo_texture = load("res://Temp/" + filename)
		var normal_filename = base_name + normal_suffix
		
		mat.albedo_texture = albedo_texture
		
		if normal_filename in normal_maps:
			var normal_texture = load("res://Temp/" + normal_filename)
			mat.normal_enabled = true
			mat.normal_texture = normal_texture
		
		var material_path = "res://Temp/MI_" + base_name.substr(2) + ".tres"
		
		ResourceSaver.save(mat, material_path)
		
		
		
		
