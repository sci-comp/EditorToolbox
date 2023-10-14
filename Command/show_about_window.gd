@tool
extends EditorPlugin

var vbox : VBoxContainer
var title : Label
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
	title.text = "This is an example for creating popup windows."
	vbox.add_child(title)

	# Ok button
	ok_button = Button.new()
	ok_button.text = "Ok"
	ok_button.pressed.connect(_on_ok_pressed)
	
	vbox.add_child(ok_button)

func _on_ok_pressed():
	popup_instance.queue_free()
	emit_signal("done")

