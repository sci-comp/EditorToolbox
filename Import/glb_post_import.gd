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
				
				# If multiple top level nodes exist, then the prefab name
				# will be set to the name of the top node in Blender.
				if (object_name_without_prefix_or_suffix == ""):
					object_name_without_prefix_or_suffix = node.name.split("_", false, 1)[1]
				
				# Does nothing if a material is not found
				assign_external_material(node)
				
				var children = node.get_children()
				for child in children:
					print("Child: " + child.name)
					
					# Is the child object a custom collision mesh?
					if array_contains_substring(child.name, phys_material_map.keys()):
						
						var object_name_with_prefix = child.name.split("-", false, 1)[0]
						
						# TODO: Convert child object depending on the mesh suffix
						
						# 1) Delete the existing child object (it should be a MeshInstance3D node)
						# 2) Create a StaticBody3D node in its place
						# 3) Create a CollisionShape3D node as a child to the StaticBody3D node.
						# 4) Assign collision mesh to the CollisionShape3D node depending on the suffix present.
						# 5) Assign physics material by calling assign_physics_material(node) where node is the StaticBody3D node.
						
						"""
						Custom suffixes represent: box, sphere, capsule, convex, concave mesh colliders 
						respectively,

							-gbx
							-gsp
							-gcp
							-gcx
							-gcc
						"""
	
	scene.name = "PF_" + object_name_without_prefix_or_suffix + "-n1"
	print("Finished importing: " + scene.name)
	
	return scene

func array_contains_substring(_name: String, possible_options: Array) -> bool:
	for option in possible_options:
		if _name.find(option) != -1:
			return true
	return false

func assign_external_material(_node: Node3D):
	
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
					_node.mesh.surface_set_material(0, material_resource)
			
		else:
			print("JSON Parse Error: ", error_code)
		
		file.close()

func assign_physics_material(_node: Node3D):
	# Lookup and assign physics material from the suffix
	for key in phys_material_map.keys():
		if key in _node.name:
			_node.physics_material_override = phys_material_map[key]
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
					return result
			else:
				if file_name.find(material_name) != -1 and file_name.ends_with(".tres") and file_name.begins_with(mi_prefix):
					print("Found material, returning: " + full_path)
					return full_path
			file_name = dir.get_next()
	return ""


