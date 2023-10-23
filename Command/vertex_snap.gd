# Note: This program was originally made by jgillich
# Original source: https://github.com/jgillich/godot-snappy
# License: MIT

@tool
extends EditorPlugin

const RAY_LENGTH = 1000
const VECTOR_INF = Vector3(INF, INF, INF)

@onready var undo_redo = get_undo_redo()
var undo_positions = {}
var selection = get_editor_interface().get_selection()
var selected_nodes = {}
var dragging = false
var origin = Vector3()
var origin_2d = null

func _enter_tree():
	selection.connect("selection_changed", _on_selection_changed)

func _handles(object):
	return object is Node3D

func _forward_3d_draw_over_viewport(overlay):
	if origin_2d:
		overlay.draw_circle(origin_2d, 4, Color.YELLOW)

func _forward_3d_gui_input(camera, event):
	if selected_nodes.size() == 0 or not event is InputEventMouse:
		return false
	
	var now_dragging = event.button_mask == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_V)
	if dragging and not now_dragging and origin != VECTOR_INF:
		undo_redo.create_action("Snap vertex")
		for node in selected_nodes.keys():
			undo_redo.add_do_property(node, "position", node.position)
			undo_redo.add_undo_property(node, "position", undo_positions[node])
		undo_redo.commit_action()
	
	dragging = now_dragging

	if Input.is_key_pressed(KEY_V):
		var from = camera.project_ray_origin(event.position)
		var direction = camera.project_ray_normal(event.position)
		var to = from + direction * RAY_LENGTH

		if not dragging:
			var meshes = []
			for node in selected_nodes.keys():
				meshes += find_meshes(node)
			origin = find_closest_point(meshes, from, direction)
			
			for node in selected_nodes.keys():
				undo_positions[node] = node.position

			if origin != VECTOR_INF:
				origin_2d = camera.unproject_position(origin)
			else:
				origin_2d = null
			update_overlays()

		elif origin != VECTOR_INF:
			origin_2d = camera.unproject_position(origin)
			update_overlays()

			var ids = RenderingServer.instances_cull_ray(from, to, selected_nodes.keys()[0].get_world_3d().scenario)
			var meshes = []
			for id in ids:
				var obj = instance_from_id(id)
				if obj not in selected_nodes and obj.get_parent() not in selected_nodes and obj is Node3D:
					meshes += find_meshes(obj)

			var target = find_closest_point(meshes, from, direction)
			if target != VECTOR_INF:
				var offset = origin - target
				for node in selected_nodes.keys():
					node.global_position -= offset
				origin = target
			return true
	else:
		origin = VECTOR_INF
		origin_2d = null
		update_overlays()

	return false

func _on_selection_changed():
	selected_nodes.clear()
	undo_positions.clear()
	var nodes = selection.get_selected_nodes()
	for node in nodes:
		if node is Node3D:
			selected_nodes[node] = true
			undo_positions[node] = node.position

func find_meshes(node: Node3D) -> Array:
	var meshes = []
	if node is MeshInstance3D:
		meshes.append(node)

	for child in node.get_children():
		if child is Node3D:
			meshes += find_meshes(child)

	return meshes

func find_closest_point(meshes: Array, from: Vector3, direction: Vector3) -> Vector3:
	var closest = VECTOR_INF
	var closest_distance = INF
	var segment_start = from
	var segment_end = from + direction * RAY_LENGTH

	for mesh in meshes:
		var vertices = mesh.get_mesh().get_faces()
		for i in range(vertices.size()):
			var current_point = mesh.global_transform * vertices[i]
			var current_on_ray = Geometry3D.get_closest_point_to_segment_uncapped(
				current_point, segment_start, segment_end)
			var current_distance = current_on_ray.distance_to(current_point)

			if closest == VECTOR_INF or current_distance < closest_distance:
				closest = current_point
				closest_distance = current_distance

	return closest
