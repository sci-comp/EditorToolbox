"""
Godot Import Pipeline for Blender Assets
========================================

This script processes Blender exports with custom naming conventions to create
collision bodies and physics materials. Objects are exported individually from
Blender with their children to generate proper collision hierarchies.

License: MIT, by Paul

Naming Conventions
------------------

Prefixes (Blender -> Godot):
 SM_ -> StaticBody3D + MeshInstance3D
 AB_ -> AnimatableBody3D
 SK_ -> SkeletalMesh (preserved)
 M_  -> Mesh data

Collision Suffixes:
 -gbx : BoxShape3D
 -gsp : SphereShape3D  
 -gcp : CapsuleShape3D
 -gcy : CylinderShape3D
 -gcx : ConvexPolygonShape3D
 -gcc : ConcavePolygonShape3D

Physics Materials (optional):
 -cloth, -dirt, -glass, -ice, -metal, -organic, -plastic, -stone, -wood

Multiple Collision Shapes
-------------------------
To create multiple collision shapes for a single object, add collision objects
as children of the main SM_ object in Blender. Each child should follow the
pattern: SM_ObjectName-[material]-[collision]-[variant]

Example:
 SM_Crate_01                          // Main renderable object
 |-- SM_Crate_01-metal-gbx            // Box collision for metal parts
 |-- SM_Crate_01-wood-gcx_001         // Convex collision for wood parts
 |-- SM_Crate_01-cloth-gsp_002        // Sphere collision for cloth parts

Results in Godot:
 PF_Crate_01-n1 (MeshInstance3D)
 |-- SB_Crate_01-metal-gbx (StaticBody3D)
 |   |-- CS_Crate_01-metal-gbx (CollisionShape3D)
 |-- SB_Crate_01-wood-gcx_001 (StaticBody3D)
 |   |-- CS_Crate_01-wood-gcx_001 (CollisionShape3D)
 |-- SB_Crate_01-cloth-gsp_002 (StaticBody3D)
	 |-- CS_Crate_01-cloth-gsp_002 (CollisionShape3D)

Note: Do not mix Godot's built-in collision suffixes (-col, -convcol, etc.) 
with these custom ones.
"""

@tool
extends EditorScenePostImport

var phys_material_to_resource_map = {
	"-cloth": preload("res://addons/StandardAssets/PhysicsMaterial/Cloth.tres") as PhysicsMaterial,
	"-dirt": preload("res://addons/StandardAssets/PhysicsMaterial/Dirt.tres") as PhysicsMaterial,
	"-glass": preload("res://addons/StandardAssets/PhysicsMaterial/Glass.tres") as PhysicsMaterial,
	"-ice": preload("res://addons/StandardAssets/PhysicsMaterial/Ice.tres") as PhysicsMaterial,
	"-metal": preload("res://addons/StandardAssets/PhysicsMaterial/Metal.tres") as PhysicsMaterial,
	"-organic": preload("res://addons/StandardAssets/PhysicsMaterial/Organic.tres") as PhysicsMaterial,
	"-plastic": preload("res://addons/StandardAssets/PhysicsMaterial/Plastic.tres") as PhysicsMaterial,
	"-stone": preload("res://addons/StandardAssets/PhysicsMaterial/Stone.tres") as PhysicsMaterial,
	"-wood": preload("res://addons/StandardAssets/PhysicsMaterial/Wood.tres") as PhysicsMaterial,
}

var phys_material_to_layer_map = {
	"-cloth": 1 << 24 - 1,
	"-dirt": 1 << 25 - 1,
	"-glass": 1 << 26 - 1,
	"-ice": 1 << 27 - 1,
	"-metal": 1 << 28 - 1,
	"-organic": 1 << 29 - 1,
	"-plastic": 1 << 30 - 1,
	"-stone": 1 << 31 - 1,
	"-wood": 1 << 32 - 1,
}

var collision_options = [ "-gbx", "-gsp", "-gcp", "-gcx", "-gcc", "-gcy" ]

func _post_import(scene : Node):	
	var imported_scene_root = scene.get_child(0)
	
	if imported_scene_root == null:
		printerr("Imported scene root is null")
		return Node.new()
	
	if not imported_scene_root.name.contains("_"):
		print("This scene does not have the usual naming convention. Returning as-is, ", scene.name)
		return scene
	
	var object_prefix = imported_scene_root.name.split("_", false, 1)[0]
	var object_name = imported_scene_root.name.split("_", false, 1)[1]
	
	if object_prefix == "SM":
		
		assign_external_material(imported_scene_root, object_name)
		
		var children = imported_scene_root.get_children()
		if children.is_empty():
			print("Returning only a MeshInstance3D node")
			imported_scene_root.name = "PF_" + object_name + "-n1"
			return scene
		else:
			var i = 0
			for child : MeshInstance3D in children:
				i += 1
				
				# Remove after testing, get_children never returns null?
				#if !child:
				#	printerr("Child is null")
				#	return Node.new()
				
				var col_suffix = array_contains_substring(collision_options, child.name)
				if col_suffix != "":
					# Example pattern: SM_Crate_01-gbx-wood_001
					print("Collision option found for static body 3d: " + col_suffix)
					
					var phys_material = array_contains_substring(phys_material_to_resource_map.keys(), child.name)
					var static_body = StaticBody3D.new()
					var collision_shape = CollisionShape3D.new()
					
					# Assign names
					var name_suffix = object_name + phys_material + col_suffix
					static_body.name = "SB_" + name_suffix
					collision_shape.name = "CS_" + name_suffix
					
					if i > 0:
						static_body.name += "_" + str(i).pad_zeros(2)
						collision_shape.name += "_" + str(i).pad_zeros(2)
					
					scene.add_child(static_body)
					static_body.set_owner(scene)
					static_body.add_child(collision_shape)
					collision_shape.set_owner(scene)
					
					static_body.transform.origin = child.transform.origin
					assign_physics_material_from_suffix(static_body)
					generate_collision_shape(child, collision_shape, col_suffix)
					
					# Free the original child
					child.get_parent().remove_child(child)
					child.free()
				
				else:
					print("Collision suffix not found, assigning a material instead")
					assign_external_material(child, object_name)
			
			imported_scene_root.name = "MI_" + object_name
			scene.name = "PF_" + object_name + "-n1"
			return scene
	
	elif object_prefix == "AB":
		imported_scene_root.name = "MI_" + object_name
		var children = imported_scene_root.get_children()
		if children.size() == 0:
			printerr("AnimatableBody3D should have one or more children")
			return Node.new()
		elif children.size() == 1:
			var collision_mesh_instance_3d : MeshInstance3D = children[0]
			
			var col_suffix = array_contains_substring(collision_options, collision_mesh_instance_3d.name)
			if col_suffix != "":
				# Example pattern: Crate_01-gbx-wood_001
				print("Collision option found for animatable body: " + col_suffix)
				
				var phys_material = array_contains_substring(phys_material_to_resource_map.keys(), collision_mesh_instance_3d.name)
				var animatable_body = AnimatableBody3D.new()
				var collision_shape = CollisionShape3D.new()
				
				animatable_body.name = "AB_" + collision_mesh_instance_3d.name
				collision_shape.name = "CS_" + collision_mesh_instance_3d.name
				
				scene.add_child(animatable_body)
				animatable_body.set_owner(scene)
				animatable_body.add_child(collision_shape)
				collision_shape.set_owner(scene)
				
				# Reparent mesh instance to animatable body
				scene.remove_child(imported_scene_root)
				imported_scene_root.set_owner(null)
				animatable_body.add_child(imported_scene_root)
				imported_scene_root.set_owner(scene)
				assign_external_material(imported_scene_root, object_name)
				
				assign_physics_material_from_suffix(animatable_body)
				generate_collision_shape(collision_mesh_instance_3d, collision_shape, col_suffix)
				
				scene.remove_child(collision_mesh_instance_3d)
				collision_mesh_instance_3d.free()
				
				return animatable_body
				
			else: 
				printerr("Missing collision suffix")
			
			return 
		else:
			var first_animatable_body
			var i = 0
			for collision_mesh_instance_3d : MeshInstance3D in children:
				i += 1
				
				var col_suffix = array_contains_substring(collision_options, collision_mesh_instance_3d.name)
				if col_suffix != "":
					print("Collision option found for animatable body: " + col_suffix)
					
					var phys_material = array_contains_substring(phys_material_to_resource_map.keys(), collision_mesh_instance_3d.name)
					var animatable_body = AnimatableBody3D.new()
					var collision_shape = CollisionShape3D.new()
					
					if i == 1:
						first_animatable_body = animatable_body
					
					animatable_body.name = "AB_" + collision_mesh_instance_3d.name
					collision_shape.name = "CS_" + collision_mesh_instance_3d.name
					
					scene.add_child(animatable_body)
					animatable_body.set_owner(scene)
					animatable_body.add_child(collision_shape)
					collision_shape.set_owner(scene)
					
					assign_physics_material_from_suffix(animatable_body)
					generate_collision_shape(collision_mesh_instance_3d, collision_shape, col_suffix)
				else: 
					printerr("Missing collision suffix")
					continue
				
				# Free the original child
				collision_mesh_instance_3d.get_parent().remove_child(collision_mesh_instance_3d)
				collision_mesh_instance_3d.free()
			
			scene.remove_child(imported_scene_root)
			imported_scene_root.set_owner(null)
			first_animatable_body.add_child(imported_scene_root)
			imported_scene_root.set_owner(scene)
			assign_external_material(imported_scene_root, object_name)
			
			return scene
	
	elif object_prefix == "SK":
		print("Skeletal mesh detected")
		var children = imported_scene_root.get_children()
		if (children.size() == 0):
			printerr("Skeletal mesh has no children?")
			return scene
		assign_external_material_recursively(imported_scene_root)
		
		return scene
	
	print("No matching prefix found, returning node as is.")
	return scene

func array_contains_substring(possible_options: Array, _name: String) -> String:
	for option in possible_options:
		if _name.find(option) != -1:
			return option
	return ""

func assign_external_material(_node: MeshInstance3D, _object_name: String):
	
	var file_path = get_source_file()
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		print("file found: ", file_path)
		var magic = file.get_32()
		var version = file.get_32()
		var length = file.get_32()
		var chunk_length = file.get_32()
		var chunk_type = file.get_32()
		var json_data = file.get_buffer(chunk_length).get_string_from_utf8()
		var json = JSON.new()
		var error_code = json.parse(json_data)
		
		if error_code == OK:
			
			# Extract material name from the glb
			var parsed_json_data = json.get_data()
			
			if not parsed_json_data.has("nodes") or parsed_json_data["nodes"].is_empty():
				printerr("Invalid JSON structure")
				return
			
			# Extract which mesh the root node references
			# Unused, but left here for reference. Code instead searches by name
			# var first_object_mesh_index = parsed_json_data["nodes"][0].get("mesh", -1)
			
			# parsed_json_data["meshes"] contains an index for the material 
			# assigned to the given submesh
			var material_names = []
			for item in parsed_json_data["meshes"]:
				if item["name"] == "M_" + _object_name:
					for submesh in item["primitives"]:
						var material_idx = submesh["material"]
						material_names.append(parsed_json_data["materials"][material_idx]["name"])
					print("Material names from glb: " + str(material_names))
			
			for i in range(material_names.size()):
				var material_path = search_material_resource(material_names[i])
				if material_path:
					var material_resource = ResourceLoader.load(material_path) as Material
					if material_resource:
						_node.mesh.surface_set_material(i, material_resource)
					else:
						print("Material unsuccessfully loaded.")
				else:
					print("Path for external material not found.")
		
		else:
			print("JSON Parse Error: ", error_code)
		
		file.close()
	
	else:
		print("File not found: " + file_path)

func assign_physics_material_from_suffix(body : CollisionObject3D) -> void:
	for key : String in phys_material_to_resource_map.keys():
		if key in body.name:
			body.physics_material_override = phys_material_to_resource_map[key]
			body.collision_layer |= phys_material_to_layer_map[key]
			print("Physics material assigned: " + key)
			break

func generate_collision_shape(subject : MeshInstance3D, collision_shape : CollisionShape3D, _col_suffix : String) -> void:
	
	var mesh = subject.mesh
	var bbox = mesh.get_aabb()
	var shape
	
	match _col_suffix:
		"-gbx":
			shape = BoxShape3D.new()
			shape.extents = bbox.size * 0.5
			collision_shape.position = bbox.get_center()
		"-gsp":
			shape = SphereShape3D.new()
			shape.radius = max(bbox.size.x, bbox.size.y, bbox.size.z) * 0.5
			collision_shape.position.y = bbox.position.y + (bbox.size.y * 0.5)
		"-gcp":
			shape = CapsuleShape3D.new()
			shape.radius = min(bbox.size.x, bbox.size.z) * 0.5
			shape.height = bbox.size.y
			collision_shape.position.y = bbox.position.y + (bbox.size.y * 0.5)
		"-gcy":
			shape = CylinderShape3D.new()
			shape.radius = bbox.size.z * .5
			shape.height = bbox.size.y
			collision_shape.position.y = bbox.position.y + (bbox.size.y * .5)
			collision_shape.position.x = bbox.position.x + (bbox.size.x * .5)
			collision_shape.position.z = bbox.position.z + (bbox.size.z * .5)
		"-gcx":
			shape = ConvexPolygonShape3D.new()
			shape.set_points(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
		"-gcc":
			shape = ConcavePolygonShape3D.new()
			var surface_arrays = mesh.surface_get_arrays(0)
			var vertices = surface_arrays[Mesh.ARRAY_VERTEX]
			var indices = surface_arrays[Mesh.ARRAY_INDEX]
			var faces = PackedVector3Array()
			for j in range(0, indices.size(), 3):
				if j + 2 < indices.size() and indices[j + 2] < vertices.size():
					faces.append(vertices[indices[j]])
					faces.append(vertices[indices[j + 1]])
					faces.append(vertices[indices[j + 2]])
				else:
					printerr("Invalid index access in mesh data")
			shape.set_faces(faces)
		"-":
			print("Error: Collision option not matched: ", _col_suffix)
	
	collision_shape.shape = shape

func search_material_resource(material_name: String, start_dir: String = "res://", mi_prefix: String = "MI_") -> String:
	# Searches the entire project for a resource with material_name. Returns the first path found.
	var dir = DirAccess.open(start_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = start_dir + file_name
			if dir.current_is_dir():
				var result = search_material_resource(material_name, full_path + "/")
				if result:
					return result  # Step into directory
			else:
				if (file_name == material_name + ".tres"): # and file_name.ends_with(".tres"): # and file_name.begins_with(mi_prefix):
					print("Found material: " + full_path)
					return full_path
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Unable to open directory: " + dir)
	return ""

func assign_external_material_recursively(node):
	var children = node.get_children()
	if children.is_empty():
		return
	for child in children:
		if child.name.begins_with("SM_"):
			var _object_name = child.name.replace("SM_", "")
			var mesh_instance = child as MeshInstance3D
			print("Assigning a material to child node: ", child.name)
			assign_external_material(mesh_instance, _object_name)
		assign_external_material_recursively(child)
