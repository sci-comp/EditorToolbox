@tool
extends EditorScenePostImport

var phys_material_map = {
	"-cloth": preload("res://addons/StandardAssets/PhysicsMaterial/phys_cloth.tres") as PhysicsMaterial,
	"-dirt": preload("res://addons/StandardAssets/PhysicsMaterial/phys_dirt.tres") as PhysicsMaterial,
	"-glass": preload("res://addons/StandardAssets/PhysicsMaterial/phys_glass.tres") as PhysicsMaterial,
	"-ice": preload("res://addons/StandardAssets/PhysicsMaterial/phys_ice.tres") as PhysicsMaterial,
	"-metal": preload("res://addons/StandardAssets/PhysicsMaterial/phys_metal.tres") as PhysicsMaterial,
	"-plastic": preload("res://addons/StandardAssets/PhysicsMaterial/phys_plastic.tres") as PhysicsMaterial,
	"-stone": preload("res://addons/StandardAssets/PhysicsMaterial/phys_stone.tres") as PhysicsMaterial,
	"-wood": preload("res://addons/StandardAssets/PhysicsMaterial/phys_wood.tres") as PhysicsMaterial,
}

func _post_import(scene : Node):
	
	print("Inside _post_import with external materials: " + get_source_file())
	
	var pattern = "SM_(\\w+)_M_\\1.*"  # Mesh naming pattern from Blender
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var scene_name = "PF_"
	
	for node in scene.get_children():
		
		if node is MeshInstance3D:
			
			# -----------------------------------------------------------------
			# Assign external material
			
			var file_path = get_source_file()
			var file = FileAccess.open(file_path, FileAccess.READ)
			
			if file:
				
				var magic = file.get_32()
				var version = file.get_32()
				var length = file.get_32()
				var chunk_length = file.get_32()
				var chunk_type = file.get_32()
				var json_data = file.get_buffer(chunk_length).get_string_from_utf8()
				var json = JSON.new()
				var error_code = json.parse(json_data)

				if error_code == OK:
					
					var parsed_json_data = json.get_data()
					var material_name_from_glb = parsed_json_data["materials"][0]["name"]
					var external_material_path = search_material_resource(material_name_from_glb)
					
					if external_material_path:
						var material_resource = ResourceLoader.load(external_material_path) as Material
						if material_resource:
							node.mesh.surface_set_material(0, material_resource)
					
				else:
					print("JSON Parse Error: ", error_code)
				
				file.close()
			
			# -----------------------------------------------------------------
			# Assign physics material, ex, M_Broom_01-wood-convcol
			
			if (node.get_child_count() == 1):
				
				# If the MeshInstance3D node has a child, then it should be a 
				# StaticBody3D node, and this node's mesh property should have
				# a suffix.
				
				var staticBody3D = node.get_child(0)
				if staticBody3D is StaticBody3D:
					var phys_material
					for key in phys_material_map.keys():
						if key in node.mesh.resource_name:
							phys_material = phys_material_map[key]
							break
					if phys_material is PhysicsMaterial:
						staticBody3D.physics_material_override = phys_material
			
			# -----------------------------------------------------------------
	
		elif node is StaticBody3D:
			
			# Multiple StaticBody3D nodes may exists as siblings to a 
			# MeshInstance3D node.
			
			var object_name = node.name.split("_")[1]
			
			if (object_name == null):
				print("object_name is null")
			else:
				var phys_material
				for key in phys_material_map.keys():
					if key in node.name:
						phys_material = phys_material_map[key]
						break
				if phys_material is PhysicsMaterial:
					node.physics_material_override = phys_material
		
		var _temp = node.name.split("-")[0].split("_")
		var _sliced = _temp.slice(1, _temp.size())  # One or more
		scene_name = ""
		
		for i in _sliced:
			scene_name += i
			if i != _sliced[-1] and _sliced.size() > 1:
				scene_name += "_"
	
	scene.name = "PF_" + scene_name + "-n1"
	print("Finished importing: " + scene.name)
	return scene
	
# Searches the entire project for a resource with material_name. Returns the first path found.
func search_material_resource(material_name: String, start_dir: String = "res://", mi_prefix: String = "MI_") -> String:
	var dir = DirAccess.open(start_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = start_dir + file_name
			if dir.current_is_dir():
				var result = search_material_resource(material_name, full_path + "/")
				if result:
					return result
			else:
				if file_name.find(material_name) != -1 and file_name.ends_with(".tres") and file_name.begins_with(mi_prefix):
					print("Found material, returning: " + full_path)
					return full_path
			file_name = dir.get_next()
	return ""

