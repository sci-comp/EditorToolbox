extends EditorPlugin

var popup_instance : PopupPanel
var vbox : VBoxContainer
var title : Label
var infobox : Label
var field_prefab_name : LineEdit
var ok_button : Button
var close_button : Button

func _enter_tree():
	execute()

func execute():
	popup_instance = PopupPanel.new()
	add_child(popup_instance)
	popup_instance.popup_centered(Vector2(300, 200))

	vbox = VBoxContainer.new()
	popup_instance.add_child(vbox)

	title = Label.new()
	title.text = "Create Prefab"
	vbox.add_child(title)

	infobox = Label.new()
	infobox.text = "This script assumes that three files have been selected. For an example Prefab \"PF_Trident\", then the three selected files could be: MI_Trident, M_Trident_UCX, and M_Trident_DRAW, where _DRAW represends a high poly mesh that auto-lod is applied to. The collision mesh has possible suffixes: UCX, UNCX, USPX, or UCPX. The material prefix is MI_"
	infobox.clip_text = false
	infobox.autowrap = true
	vbox.add_child(infobox)

	field_prefab_name = LineEdit.new()
	field_prefab_name.text = "Trident"
	vbox.add_child(field_prefab_name)

	ok_button = Button.new()
	ok_button.text = "Ok"
	ok_button.pressed.connect(_on_ok_pressed)
	vbox.add_child(ok_button)

	close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close_pressed)
	vbox.add_child(close_button)

func _on_ok_pressed():
	var selected_paths = get_editor_interface().get_selected_paths()
	
	if selected_paths.size() < 2:
		return

	var new_node = Node3D.new()
	new_node.name = field_prefab_name.text
	get_editor_interface().get_edited_scene().add_child(new_node)

	var mesh_instance = MeshInstance3D.new()
	var collision_shape = CollisionShape3D.new()

	new_node.add_child(mesh_instance)
	new_node.add_child(collision_shape)

	var mesh_collision
	var mesh_draw
	var material

	for path in selected_paths:
		var file_name = path.get_file()
		var base_name = file_name.get_basename()

		if base_name.begins_with("M_Trident_"):
			var suffix = base_name.get_slice("_", 2)

			if suffix == "DRAW":
				mesh_draw = load(path)
			elif suffix in ["USPX", "UCPX", "UNCX", "UCX", "UBX"]:
				mesh_collision = load(path)

		elif base_name.begins_with("MI_Trident"):
			material = load(path)

	if mesh_collision and mesh_draw and material:
		mesh_instance.mesh = mesh_draw
		mesh_instance.set_surface_material(0, material)

		collision_shape.shape = mesh_collision

	popup_instance.queue_free()

func _on_close_pressed():
	popup_instance.queue_free()
