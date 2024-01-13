extends Node

static func replace_first(s: String, pattern: String, replacement: String) -> String:
	var index = s.find(pattern)
	if index == -1:
		return s
	return s.substr(0, index) + replacement + s.substr(index + pattern.length())

static func replace_last(s: String, pattern: String, replacement: String) -> String:
	var index = s.rfind(pattern)
	if index == -1:
		return s
	return s.substr(0, index) + replacement + s.substr(index + pattern.length())

static func get_unique_name(base_name: String, parent: Node) -> String:
	var new_name = base_name
	var count = 1
	var ends_with_digit = base_name.match(".*\\d+$")
	
	var regex = RegEx.new()
	regex.compile("^(.*?)(\\d+)$")
	
	print("Searching for a unique name...")
	
	if (parent.has_node(base_name)):
		print("Existing name has been taken.")
		while parent.has_node(new_name):
			if ends_with_digit:
				var result = regex.search(new_name)
				
				if result:
					print(new_name)
					var name_part = result.get_string(1)
					var num_part = int(result.get_string(2))
					print(name_part)
					print(num_part)
					new_name = name_part + str(num_part + count)
				else:
					new_name = base_name + str(count)
			else:
				new_name = base_name + str(count)
				
			count += 1
	else:
		print("Existing name may be used as is.")
		
	print("Returning: " + new_name)
	
	return new_name
