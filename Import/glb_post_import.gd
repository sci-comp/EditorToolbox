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
	
	print("Inside glb _post_import")
	
	var pattern = "SM_(\\w+)_M_\\1.*"  # Mesh naming pattern from Blender
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var mesh_resource_name
	
	for node in scene.get_children():
		
		if node is MeshInstance3D:
			
			# Physics materials are automatically detected
			# ex) M_Broom_01-wood-convcol
			var phys_material
			mesh_resource_name = node.mesh.resource_name
			for key in phys_material_map.keys():
				if key in mesh_resource_name:
					phys_material = phys_material_map[key]
			if phys_material is PhysicsMaterial:
				for i in range(node.get_child_count()):
					var staticBody3D = node.get_child(i)
					if staticBody3D is StaticBody3D:
						staticBody3D.physics_material_override = phys_material
						break
	
	# Set the instantiated node's name
	var result = regex.search(mesh_resource_name)
	if result:
		scene.name = "PF_" + result.get_string(1) + "-n1"
	
	print("Finished importing: " + scene.name)
	
	return scene
