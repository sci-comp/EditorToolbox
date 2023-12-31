@tool
extends EditorPlugin

var vbox : VBoxContainer
var title : Label
var field_prefix_to_add : LineEdit
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
	title.text = "Add prefix."
	vbox.add_child(title)

	# HBoxContainer for the existing
	var hbox_prefix_to_add = HBoxContainer.new()
	var label_prefix_to_add = Label.new()
	label_prefix_to_add.text = "Existing pattern"
	field_prefix_to_add = LineEdit.new()
	field_prefix_to_add.text = ""
	vbox.add_child(hbox_prefix_to_add)
	hbox_prefix_to_add.add_child(label_prefix_to_add)
	hbox_prefix_to_add.add_child(field_prefix_to_add)
	
	# Ok button
	ok_button = Button.new()
	ok_button.text = "Add prefix to selected"
	ok_button.pressed.connect(_on_ok_pressed)
	
	vbox.add_child(ok_button)

func _on_ok_pressed():
	
	okay_was_pressed()
	
	popup_instance.queue_free()
	emit_signal("done")

func okay_was_pressed():
	
	var editor_selection = get_editor_interface().get_selection()
	var selected_nodes = editor_selection.get_selected_nodes()
	
	for _node in selected_nodes:
		_node.name = field_prefix_to_add.text + _node.name
