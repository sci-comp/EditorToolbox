@tool
extends EditorScenePostImport

var material_map = {
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
	
	var mesh_resource_name
	
	for node in scene.get_children():
		if node is MeshInstance3D:
			var material
			mesh_resource_name = node.mesh.resource_name
			for key in material_map.keys():
				if key in mesh_resource_name:
					material = material_map[key]
			
			if material is PhysicsMaterial:
				for i in range(node.get_child_count()):
					var staticBody3D = node.get_child(i)
					if staticBody3D is StaticBody3D:
						staticBody3D.physics_material_override = material
						break
	
	var pattern = "SM_(\\w+)_M_\\1.*"
	var regex = RegEx.new()
	regex.compile(pattern)

	var result = regex.search(mesh_resource_name)
	if result:
		scene.name = "PF_" + result.get_string(1)
		
	print(scene.name)
	
	return scene
