extends Node

var item_path_lookup : Dictionary = {}
var craftable_items : Array[Item] = []


func _ready() -> void:
	construct_item_lookup_resources()

func construct_item_lookup_resources():
	var start_time := Time.get_ticks_msec()
	for_each_in_directory("res://resources/items/", func(item: Resource):
		if item is Item:
			item_path_lookup[item.key] = item.resource_path
			if not item.recipe == null:
				craftable_items.push_back(item)
	)
	print("Indexing items and recipes took {needed_time} msec".format({"needed_time" : Time.get_ticks_msec() - start_time }))
	
func convert_item_keys_to_items(keys: Array[Variant]) -> Array[Item]:
	var item_array : Array[Item] = []
	for item_key in keys:
		if item_key == null: 
			item_array.push_back(null)
			continue
		var item_path : String = ItemContext.item_path_lookup[item_key]
		if not item_path or not item_path.begins_with("res://resources/items/"): item_array.push_back(null)
		var item : Item = load(item_path) as Item
		if item is not Item: item_array.push_back(null)
		item_array.push_back(item)
	return item_array
	
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
