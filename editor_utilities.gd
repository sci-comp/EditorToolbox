func replace_first(s: String, pattern: String, replacement: String) -> String:
	var index = s.find(pattern)
	if index == -1:
		return s
	return s.substr(0, index) + replacement + s.substr(index + pattern.length())

func replace_last(s: String, pattern: String, replacement: String) -> String:
	var index = s.rfind(pattern)
	if index == -1:
		return s
	return s.substr(0, index) + replacement + s.substr(index + pattern.length())
