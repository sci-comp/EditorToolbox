@tool
extends EditorPlugin

var arr : Array = []
var vbox : VBoxContainer
var export_field : Label
var ok_button : Button
var popup_instance : PopupPanel

func execute():
	# Initialize PopupPanel
	popup_instance = PopupPanel.new()
	add_child(popup_instance)
	
	# Handle selected paths
	arr = get_editor_interface().get_selected_paths()
	popup_instance.popup_centered(Vector2(300, 200))

	# Initialize VBox
	vbox = VBoxContainer.new()
	popup_instance.add_child(vbox)

	# Initialize Label
	export_field = Label.new()
	export_field.text = "Drop objects here"
	vbox.add_child(export_field)

	# Initialize Ok Button
	ok_button = Button.new()
	ok_button.text = "Ok"
	ok_button.pressed.connect(_on_ok_pressed)
	vbox.add_child(ok_button)

	

func _on_ok_pressed():
	for obj in arr:
		print(obj)
