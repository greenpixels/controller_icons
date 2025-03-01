@tool
extends EditorScript

func _run():
	print("Starting mapping ... ")
	var mapping: Dictionary = {}
	var base_path: String = "res://object_scenes/blocks/"
	_scan_directory(base_path, mapping)
	_save_mapping(mapping)

func _scan_directory(path: String, mapping: Dictionary):
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name == "_all":
					_scan_directory(path + file_name + "/", mapping)
				elif file_name != "." and file_name != "..":
					_scan_directory(path + file_name + "/", mapping)
			elif file_name.ends_with(".tscn"):
				_process_scene_file(path + file_name, mapping)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Could not open directory: ", path)

func _process_scene_file(file_path: String, mapping: Dictionary):
	var scene: PackedScene = ResourceLoader.load(file_path)
	if scene:
		var root: Node = scene.instantiate()
		if root and root is Block:
			var key = root.key
			if key and key != "NO_KEY":
				mapping[key] = file_path
		root.queue_free() # Free the instantiated scene to avoid memory leaks
	else:
		printerr("Could not load scene: ", file_path)

func _save_mapping(mapping: Dictionary):
	print("Saving mapping ...")
	var file_content: String = "class_name BlockMappings\n\n"
	file_content += "static var block_key_to_block_resource_map: Dictionary = {\n"
	for key in mapping:
		file_content += "\t\"" + key + "\": load(\"" +  mapping[key] + "\"),\n"
	file_content += "}\n\n"

	# Create the inverse mapping
	var inverse_mapping: Dictionary = {}
	for key in mapping:
		inverse_mapping[mapping[key]] = key

	file_content += "static var block_path_to_block_key: Dictionary = {\n"
	for path in inverse_mapping:
		file_content += "\t\"" + path + "\": \"" + inverse_mapping[path] + "\",\n"
	file_content += "}\n"

	var file: FileAccess = FileAccess.open("res://object_scenes/blocks/block_mappings.gd", FileAccess.WRITE)
	if file:
		print("Writing to file ...")
		file.store_string(file_content)
		file.close()
	else:
		printerr("Could not open file for writing.")
