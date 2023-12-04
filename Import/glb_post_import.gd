"""

Native Collision Support
------------------------

Godot's default suffixes for automatically generating mesh on import are,

	-col
	-convcol
	-colonly
	-convcolonly

Godot's suffixes are not meant to be used together with the custom ones below.
Doing so will lead to undefined behavior.

Note: Godot supported suffixes are removed from the node's name before _post_process 
triggers.

Custom Prefix and Suffix Definitions
------------------------------------

Prefix and suffix conventions must be followed for this import process. The 
hypen is treated as a reserved character for object and mesh names in Blender.

prefixes represent: prefab, static mesh, and skeletal mesh respectively,

	PF_
	SM_
	SK_

In Godot, the word "scene" is perhaps a bit overloaded with meaning. The naming 
convention I have chosen does not use the word scene at all.

	Prefab: used for scenes that behave as prefabs.
	Level: used for scenes that behave as levels (additive scenes in Unity)

Custom suffixes represent: box, sphere, capsule, convex, concave mesh colliders 
respectively,

	-gbx
	-gsp
	-gcp
	-gcx
	-gcc

When a custom collision suffix is used, a physics material suffix may also be
assigned,

	-cloth
	-dirt
	-glass
	-ice
	-metal
	-plastic
	-stone
	-wood

Example 
-------

Scene Collection in Blender

[Object]    | SM_Trident_01
[Mesh]      | -- M_Trident_01
[Material]  | ---- MI_Trident_01
			| 
[Object]    | -- SM_Trident_01-gcx-metal
[Mesh]      | ---- M_Trident_01-gcx-metal
[Material]  | ---- phys_metal
			|
[Object]    | -- SM_Trident_01-gcx-metal_001
[Mesh]      | ---- M_Trident_01-gcx-metal_001
[Material]  | ---- phys_metal
			|
[Object]    | -- SM_Trident_01-gcx-metal_002
[Mesh]      | ---- M_Trident_01-gcx-metal_002
[Material]  | ---- phys_metal

Note: Materials named after Godot's physics materials are assigned to collision
mesh in Blender. This is not required, though it is helpful since materials with
appropriate colors may be used in Blender as a visual aid. This could be used as
an approach for an alternate implementation. This script, however, only looks at
materials for the rendered mesh. suffixes are used for collision mesh instead, 
and we do not assign materials to collision-only mesh.

After import,

[Node3d]            | PF_Trident_01-n1
[MeshInstance3D]    | -- SM_Trident_01
[StaticBody3D]      | -- SM_Trident_01-stone
[CollisionShape3D]  | ---- CollisionShape3D 

Single Object Example
---------------------

Scene Collection in Blender

[Object]    | SM_Trident_01-convcol-metal
[Mesh]      | -- M_Trident_01
[Material]  | ---- MI_Trident_01

"""

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

var collision_options = [ "-gbx", "-gsp", "-gcp", "-gcx", "-gcc" ]

func _post_import(scene : Node):
	
	print("_post_import for: " + get_source_file())
	
	var pattern = "SM_(\\w+)_M_\\1.*"  # Mesh naming pattern from Blender
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var object_name_without_prefix_or_suffix = ""
	
	for node in scene.get_children():
		if node is MeshInstance3D:
			
			var prefix = node.name.split("_", false, 1)[0]
			if prefix == "SM":
				
				print("In node: " + node.name)
				
				var object_name = node.name.split("_", false, 1)[1]
				if "-" in object_name:
					object_name = object_name.split("-", false, 1)[0]
				print("Object name: " + object_name)
				
				# If multiple top level nodes exist, then the prefab name
				# will be set to the name of the top node in Blender.
				if (object_name_without_prefix_or_suffix == ""):
					object_name_without_prefix_or_suffix = node.name.split("_", false, 1)[1]
				
				# Does nothing if a material is not found
				assign_external_material(node, object_name)
				
				# If collision options exist, convert MeshInstance3D to 
				# StaticBody3D with an appropriate CollisionShape3D
				var children = node.get_children()
				var i = -1
				for child in children:
					i += 1
					print("Processing: " + child.name)
					
					var col_suffix = array_contains_substring(child.name, collision_options)
					var phys_material = array_contains_substring(child.name, phys_material_map.keys())
					
					if col_suffix != "":
						if not child is MeshInstance3D:
							print("Child node is not a MeshInstance3D. Does this make sense?")
							continue
						
						print("Collision option detected: " + col_suffix)
						
						var static_body = StaticBody3D.new()
						var collision_shape = CollisionShape3D.new()
						
						static_body.name = "SB_" + object_name + col_suffix
						collision_shape.name = "CS_" + object_name + col_suffix
						if phys_material != "":
							static_body.name += phys_material
							collision_shape.name += phys_material
						static_body.name += "_" + str(i)
						collision_shape.name += "_" + str(i)
						
						var mesh = child.mesh
						var bbox = mesh.get_aabb()
						var shape
						
						scene.add_child(static_body)
						static_body.set_owner(scene)
						
						static_body.add_child(collision_shape)
						collision_shape.set_owner(scene)
						
						static_body.transform.origin = child.transform.origin
						
						print("static_body name: " + static_body.name)
						print("collision_shape name: " + collision_shape.name)
						
						match col_suffix:
							"-gbx":
								shape = BoxShape3D.new()
								shape.extents = bbox.size * 0.5
							"-gsp":
								shape = SphereShape3D.new()
								shape.radius = max(bbox.size.x, bbox.size.y, bbox.size.z) * 0.5
							"-gcp":
								shape = CapsuleShape3D.new()
								shape.radius = bbox.size.z * 0.5
								shape.height = bbox.size.y# - (shape.radius * 2.0)
							"-gcx":
								shape = ConvexPolygonShape3D.new()
								shape.set_points(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
							"-gcc":
								shape = ConcavePolygonShape3D.new()
								
								var arrays = mesh.surface_get_arrays(0)
								var vertices = arrays[Mesh.ARRAY_VERTEX]
								var indices = arrays[Mesh.ARRAY_INDEX]

								var faces = PackedVector3Array()
								for j in range(0, indices.size(), 3):
									faces.append(vertices[indices[j]])
									faces.append(vertices[indices[j + 1]])
									faces.append(vertices[indices[j + 2]])

								shape.set_faces(faces)
						
						collision_shape.shape = shape
						
						assign_physics_material(static_body)
						
						child.get_parent().remove_child(child)
						child.free()
					
					else:
						print("Collision option not found.")
			else:
				print("Supported prefix not found.")
		
	scene.name = "PF_" + object_name_without_prefix_or_suffix + "-n1"
	print("Finished importing: " + scene.name)
	
	return scene

func array_contains_substring(_name: String, possible_options: Array) -> String:
	for option in possible_options:
		if _name.find(option) != -1:
			return option
	return ""

func assign_external_material(_node: Node3D, _object_name: String):
	
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
			
			# Extract material name from the glb
			var parsed_json_data = json.get_data()
			var first_object_mesh_index = parsed_json_data["nodes"][0].get("mesh", -1)
			
			# parsed_json_data["meshes"] contains an index for the material 
			# assigned to the given submesh
			var material_indexes = []
			var material_names = []
			
			for item in parsed_json_data["meshes"]:
				if item["name"] == "M_" + _object_name:
					
					for submesh in item["primitives"]:
						var material_idx = submesh["material"]
						material_indexes.append(material_idx)
						material_names.append(parsed_json_data["materials"][material_idx]["name"])
						
					print("Material names from glb: " + str(material_names))
			
			var external_material_paths = []
			for material_name in material_names:
				external_material_paths.append(search_material_resource(material_name))
			
			var k = 0
			for external_material_path in external_material_paths:
				if external_material_path:
					var material_resource = ResourceLoader.load(external_material_path) as Material
					if material_resource:
						print("Material assigned: " + material_resource.resource_name)
						_node.mesh.surface_set_material(k, material_resource)
					else:
						print("Material unsuccesfully loaded.")
				else:
					print("Path for external material not found.")
				k += 1
		else:
			print("JSON Parse Error: ", error_code)
		
		file.close()
	else:
		print("File not found: " + file_path)

func assign_physics_material(_node: Node3D):
	# Lookup and assign physics material from the suffix
	for key in phys_material_map.keys():
		if key in _node.name:
			_node.physics_material_override = phys_material_map[key]
			print("Physics material assigned: " + key)
			break

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
				if file_name.find(material_name) != -1 and file_name.ends_with(".tres") and file_name.begins_with(mi_prefix):
					print("Found material, returning path: " + full_path)
					return full_path
			file_name = dir.get_next()
	else:
		print("Unable to open directory: " + dir)
	return ""


