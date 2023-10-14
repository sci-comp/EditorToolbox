@tool
extends EditorPlugin

# <summary>
# Takes a screenshot. Output: "res://Screenshot_%s_%s_%s_%s_%s_%s.png"
# </summary>

func execute():
	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_image()

	# Create a texture for it.
	var tex = ImageTexture.create_from_image(img)

	# Set the texture to the captured image node.
	var captured_image
	captured_image.set_texture(tex)
	
	var current_time = Time.get_datetime_dict_from_system()
	var year = str(current_time.year)
	var month = "%02d" % current_time.month
	var day = "%02d" % current_time.day
	var hour = "%02d" % current_time.hour
	var minute = "%02d" % current_time.minute
	var second = "%02d" % current_time.second

	var save_path = "res://Screenshot/Screenshot_%s_%s_%s_%s_%s_%s.png" % [year, month, day, hour, minute, second]
	captured_image.save_png(save_path)
	
