extends Node

var craftable_items : Array[Item] = []


func _ready() -> void:
	construct_craftable_items_array()

func construct_craftable_items_array():
	var start_time := Time.get_ticks_msec()
	for_each_in_directory("res://resources/items/", func(item: Resource):
		if item is Item:
			if not item.recipe == null:
				craftable_items.push_back(item)
	)
	print("Indexing crafting recipes took {needed_time} msec".format({"needed_time" : Time.get_ticks_msec() - start_time }))
	
	
func for_each_in_directory(directory: String, callback: Callable):
	var dir = DirAccess.open(directory)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var file_path = directory + "/" + file_name
			var resource_path = file_path.replace(".remap", "")
			print(resource_path)
			if dir.current_is_dir():
				for_each_in_directory(file_path, callback)
			elif resource_path.ends_with(".tres") or resource_path.ends_with(".res"):
				var res_path = resource_path
				var resource = ResourceLoader.load(res_path)
				callback.call(resource)
			
			file_name = dir.get_next()
