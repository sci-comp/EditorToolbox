@tool
extends EditorPlugin

var popup_instance : PopupPanel
var vbox : VBoxContainer
var title : Label
var field_texture_prefix : LineEdit
var field_material_prefix : LineEdit
var field_nmap_suffix : LineEdit
var checkbox_use_transparency_alpha : CheckBox
var ok_button : Button

signal done

var editor_utilities = preload("res://addons/EditorToolbox/editor_utilities.gd").new()

func execute():
	
	# Popup
	popup_instance = PopupPanel.new()
	add_child(popup_instance)
	popup_instance.popup_centered(Vector2(300, 200))

	# VBox
	vbox = VBoxContainer.new()
	popup_instance.add_child(vbox)

	# Title
	title = Label.new()
	title.text = "Create BaseMaterial3D"
	vbox.add_child(title)
	
	# Info
	var infobox = Label.new()
	infobox.text = "Create a BaseMaterial3D for each the current selection in FileSystem."
	vbox.add_child(infobox)
	
	# HBoxContainer for texture prefix
	var hbox_texture_prefix = HBoxContainer.new()
	var label_texture_prefix = Label.new()
	label_texture_prefix.text = "Texture prefix"
	field_texture_prefix = LineEdit.new()
	field_texture_prefix.text = "T_"
	vbox.add_child(hbox_texture_prefix)
	hbox_texture_prefix.add_child(label_texture_prefix)
	hbox_texture_prefix.add_child(field_texture_prefix)

	# HBoxContainer for material prefix
	var hbox_material_prefix = HBoxContainer.new()
	var label_material_prefix = Label.new()
	label_material_prefix.text = "Material prefix"
	field_material_prefix = LineEdit.new()
	field_material_prefix.text = "MI_"
	vbox.add_child(hbox_material_prefix)
	hbox_material_prefix.add_child(label_material_prefix)
	hbox_material_prefix.add_child(field_material_prefix)

	# HBoxContainer for normal map suffix
	var hbox_nmap_suffix = HBoxContainer.new()
	var label_nmap = Label.new()
	label_nmap.text = "Normal map suffix"
	field_nmap_suffix = LineEdit.new()
	field_nmap_suffix.text = "_n"
	vbox.add_child(hbox_nmap_suffix)
	hbox_nmap_suffix.add_child(label_nmap)
	hbox_nmap_suffix.add_child(field_nmap_suffix)

	# Use alpha transparency
	checkbox_use_transparency_alpha = CheckBox.new()
	checkbox_use_transparency_alpha.text = "Use alpha transparency"
	vbox.add_child(checkbox_use_transparency_alpha)

	# Ok button
	ok_button = Button.new()
	ok_button.text = "Ok"
	ok_button.pressed.connect(_on_ok_pressed)
	vbox.add_child(ok_button)

func _on_ok_pressed():
	var selected_paths = get_editor_interface().get_selected_paths()
	var texture_prefix = field_texture_prefix.text
	var material_prefix = field_material_prefix.text
	var nmap_suffix = field_nmap_suffix.text
	var texture_to_material = {}  # Maps from albedo texture path to material instance

	# Generate materials for albedo textures
	for path in selected_paths:
		var file_name = path.get_file()
		var base_name = file_name.get_basename()

		if base_name == "" or path.ends_with(".import"):
			continue

		if base_name.begins_with(texture_prefix) and !base_name.ends_with(nmap_suffix):
			var new_mat_name = material_prefix + editor_utilities.replace_first(base_name, texture_prefix, "")
			var albedo_texture = load(path)
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = albedo_texture

			if checkbox_use_transparency_alpha.is_pressed():
				mat.transparency = mat.TRANSPARENCY_ALPHA

			texture_to_material[path] = mat

	# Attach normal maps to materials
	for path in texture_to_material.keys():
		var file_name = path.get_file()
		var base_name = file_name.get_basename()
		var nmap_path = editor_utilities.replace_last(path, base_name, base_name + nmap_suffix)

		if nmap_path in selected_paths:
			var normal_texture = load(nmap_path)
			var mat = texture_to_material[path]
			mat.normal_enabled = true
			mat.normal_texture = normal_texture

	# Save materials
	for path in texture_to_material.keys():
		var dir = path.get_base_dir()
		var file_name = path.get_file()
		var base_name = file_name.get_basename()
		var new_mat_name = material_prefix + editor_utilities.replace_first(base_name, texture_prefix, "")
		var save_path = dir.path_join(new_mat_name + ".tres")

		ResourceSaver.save(texture_to_material[path], save_path)

	popup_instance.queue_free()
	emit_signal("done")


