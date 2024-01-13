@tool
extends EditorPlugin

var vbox : VBoxContainer
var title : Label
var field_existing_term : LineEdit
var field_new_term : LineEdit
var ok_button : Button
var popup_instance : PopupPanel

signal done

func execute():
	
	popup_instance = PopupPanel.new()
	add_child(popup_instance)
	
	popup_instance.popup_centered(Vector2(300, 200))

	# VBox
	vbox = VBoxContainer.new()
	popup_instance.add_child(vbox)

	# Label
	title = Label.new()
	title.text = "Replace term."
	vbox.add_child(title)

	# HBoxContainer for the existing
	var hbox_existing_term = HBoxContainer.new()
	var label_existing_term = Label.new()
	label_existing_term.text = "Existing pattern"
	field_existing_term = LineEdit.new()
	field_existing_term.text = ""
	vbox.add_child(hbox_existing_term)
	hbox_existing_term.add_child(label_existing_term)
	hbox_existing_term.add_child(field_existing_term)

	# HBoxContainer for the new term
	var hbox_new_term = HBoxContainer.new()
	var label_new_term = Label.new()
	label_new_term.text = "New pattern"
	field_new_term = LineEdit.new()
	field_new_term.text = ""
	vbox.add_child(hbox_new_term)
	hbox_new_term.add_child(label_new_term)
	hbox_new_term.add_child(field_new_term)
	
	# Ok button
	ok_button = Button.new()
	ok_button.text = "Replace term in selected paths"
	ok_button.pressed.connect(_on_ok_pressed)
	
	vbox.add_child(ok_button)

func _on_ok_pressed():
	
	okay_was_pressed()
	
	popup_instance.queue_free()
	emit_signal("done")

func okay_was_pressed():
	
	var selected_paths = get_editor_interface().get_selected_paths()
	
	var editor = get_editor_interface()
	var file_sys = editor.get_resource_filesystem()
	
	for path in selected_paths:
		
		var file_name = path.get_file()
		var base_name = file_name.get_basename()
		
		var new_file_name = ""
		if file_name.contains(field_existing_term.text):
			new_file_name = file_name.replace(field_existing_term.text, field_new_term.text)
			print("new_file_name: " + new_file_name)
		
		var dir_access = DirAccess.open(path.get_base_dir())
		if dir_access.file_exists(file_name):
			
			# Rename
			dir_access.rename(file_name, new_file_name)
			
			# Rename .import
			var import_file = file_name + ".import"
			var new_import_file = new_file_name + ".import"
			if dir_access.file_exists(import_file):
				dir_access.rename(import_file, new_import_file)
				
			print("Renamed " + file_name + " to " + new_file_name)
			
		else:
			print("File does not exist: " + file_name)
	
	editor.get_resource_filesystem().scan()

