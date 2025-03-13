@tool
extends EditorScript
class_name Mapper

func map_and_save(name_of_class: String, read_path : String, write_path: String, file_ending: String = ".tscn", should_load = false) -> void:
	print("Starting mapping ... ")
	var mapping: Dictionary = {}
	_scan_directory(read_path, mapping, file_ending)
	_save_mapping(mapping, name_of_class, write_path, should_load)

func _scan_directory(path: String, mapping: Dictionary, file_ending : String):
	var file_names = ResourceLoader.list_directory(path)
	for file_name in file_names:
		if DirAccess.dir_exists_absolute(path + file_name):
			_scan_directory(path + file_name, mapping, file_ending)
		elif file_name.ends_with(file_ending):
			if file_ending == ".tscn":
				_process_scene_file(path + file_name, mapping)
			else: mapping[file_name.replace(file_ending, "")] = path + file_name

func _process_scene_file(file_path: String, mapping: Dictionary):
	var scene: PackedScene = ResourceLoader.load(file_path)
	if scene:
		var root: Node = scene.instantiate()
		if root and "key" in root:
			if file_path.contains("block_base"):
				print(root.key)
			var key : String = root.key
			if key and not key.contains("NO_KEY") and not key.is_empty():
				mapping[key] = file_path
		root.queue_free() # Free the instantiated scene to avoid memory leaks
	else:
		printerr("Could not load scene: ", file_path)

func _save_mapping(mapping: Dictionary, name_of_class: String, saving_path: String, should_load = false):
	print("Saving mapping ...")
	var file_content: String = "class_name " + name_of_class + " \n\n"
	var const_entries = ""
	var object_map = ""
	object_map += "static var key_to_path: Dictionary[String, String] = {\n"
	for key in mapping:
		const_entries += "const " + (key as String).to_upper() + "_KEY" + " = \"" + key + "\"\n"
		const_entries += "const " + (key as String).to_upper() + "_PATH" + " = \"" + mapping[key] + "\"\n"
		object_map += "\t\"" + key + "\": \"" + mapping[key] + "\",\n"
	object_map += "}\n\n"

	# Create the inverse mapping
	var inverse_mapping: Dictionary = {}
	for key in mapping:
		inverse_mapping[mapping[key]] = key

	object_map += "static var path_to_key: Dictionary[String, String] = {\n"
	for path in inverse_mapping:
		object_map += "\t\"" + path + "\": \"" + inverse_mapping[path] + "\",\n"
	object_map += "}\n"
	
	if should_load:
		object_map += "static var key_to_loaded: Dictionary[String, Variant] = {\n"
		for key in mapping:
			object_map += "\t\"" + key + "\": ResourceLoader.load(\"" + mapping[key] + "\", \"\", ResourceLoader.CACHE_MODE_REUSE),\n"
		object_map += "}\n\n"

	var file: FileAccess = FileAccess.open(saving_path, FileAccess.WRITE)
	if file:
		print("Writing to file ...")
		file.store_string(file_content + const_entries + "\n" + object_map)
		file.close()
	else:
		printerr("Could not open file for writing.")
