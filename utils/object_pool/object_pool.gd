extends Node

var pools := {}

func get_from_pool(scene_path: String) -> Node:
	if not pools.has(scene_path):
		pools[scene_path] = []
	
	var current_pool = pools[scene_path]
	var object : Node
	
	if current_pool.is_empty():
		var packed_scene = load(scene_path)
		object = packed_scene.instantiate()
	else:
		object = current_pool.pop_back()
		
	if "_on_pool_get" in object:
		object._on_pool_get()
	
	object.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	return object
	
func add_back_to_pool(object: Node) -> void:
	var scene_path = object.scene_file_path
	if not pools.has(scene_path):
		pools[scene_path] = []
	
	if "_on_pool_return" in object:
		object._on_pool_return()
	
	pools[scene_path].push_back(object)
	object.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
