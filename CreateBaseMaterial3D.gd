@tool
extends EditorPlugin



var currentSelection : Array = []

# Popup window
var popup_instance : PopupPanel
var vbox : VBoxContainer
var title : Label
var infobox : Label
var line_edit : LineEdit
var userInput : String
var ok_button : Button

func execute():
	
	popup_instance = PopupPanel.new()
	add_child(popup_instance)
	
	# Get selection paths
	currentSelection = get_editor_interface().get_selected_paths()
	popup_instance.popup_centered(Vector2(300, 200))

	# VBox
	vbox = VBoxContainer.new()
	popup_instance.add_child(vbox)

	# Title
	title = Label.new()
	title.text = "Create BaseMaterial3D"
	vbox.add_child(title)
	
	# Info
	infobox = Label.new()
	infobox.text = "When okay is pressed, a BaseMaterial3D materials is created for each the current selection in FileSystem."
	vbox.add_child(infobox)

	line_edit = LineEdit.new()
	line_edit.text = ""
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	vbox.add_child(line_edit)

	# Ok button
	ok_button = Button.new()
	ok_button.text = "Ok"
	#ok_button.pressed.connect(_on_ok_pressed)
	
	vbox.add_child(ok_button)

func _on_line_edit_text_changed(new_text):
	userInput = new_text
	
# -- Ok button -----------------------------------------------------------------

var texture_files = []
var normal_maps = []
var normal_suffix = "_n.png"

signal done

func _on_ok_pressed():
	
	for file_path in currentSelection:
		
		var file_name = file_path.get_basename()
		
		print(file_name)
		
		if file_name == "":
			break
	
		if file_name.ends_with(".import"):
			continue
			
		if file_name.begins_with("t_"):
			texture_files.append(file_name)
			
			if file_name.ends_with(normal_suffix):
				normal_maps.append(file_name)

	for file_name in texture_files:
		
		if file_name in normal_maps:
			continue
		
		var base_name = file_name.get_basename()
		var mat = StandardMaterial3D.new()
		var albedo_texture = load("res://Temp/" + file_name)
		var file_name_n = base_name + normal_suffix
		
		mat.albedo_texture = albedo_texture
		#mat.transparency = mat.TRANSPARENCY_ALPHA
		
		if file_name_n in normal_maps:
			var normal_texture = load("res://Temp/" + file_name_n)
			mat.normal_enabled = true
			mat.normal_texture = normal_texture
		
		var material_path = "res://Temp/mi_" + base_name.substr(2) + ".tres"
		
		ResourceSaver.save(mat, material_path)
	
	popup_instance.queue_free()
	emit_signal("done")


