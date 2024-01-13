@tool
extends EditorPlugin

var vbox : VBoxContainer
var title : Label
var field_existing_term : LineEdit
var field_new_term : LineEdit
var ok_button : Button
var popup_instance : PopupPanel

var utilities = load("res://addons/EditorToolbox/editor_toolbox_utilities.gd")

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
	ok_button.text = "Replace term in selected nodes"
	ok_button.pressed.connect(_on_ok_pressed)
	
	vbox.add_child(ok_button)

func _on_ok_pressed():
	
	okay_was_pressed()
	
	popup_instance.queue_free()
	emit_signal("done")

func okay_was_pressed():
	
	var selected_nodes = get_editor_interface().get_selection()
	
	for selected in selected_nodes.get_selected_nodes():
		
		print("Trying to rename: " + selected.name)
		
		var new_name = ""
		if selected.name.contains(field_existing_term.text):
			new_name = selected.name.replace(field_existing_term.text, field_new_term.text)
			
			var unique_name = utilities.get_unique_name(new_name, selected.get_parent())
			selected.name = unique_name
			
			print("Renamed to: " + selected.name)

