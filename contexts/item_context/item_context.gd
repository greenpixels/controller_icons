extends Node

var item_path_lookup : Dictionary = {}
var craftable_items : Array[Item] = []
@onready var item_pickup_scene := preload("res://object_scenes/item_pickup/item_pickup.tscn")

func _ready() -> void:
	construct_item_lookup_resources()

# In ItemContext.gd

# Internal helper that contains the common logic.
func _spawn_item_internal(item: Item, global_position: Vector2, amount: int, _chunk_node : Node2D = null, persistance: PersistanceItemPickupState = null) -> void:
	var pickup: ItemPickup = item_pickup_scene.instantiate()
	pickup.item = item
	pickup.amount = amount
	if persistance:
		pickup.persistance = persistance
		
	var current_map = WorldContext.get_current_map()
	var chunk_node: Node2D
	# Determine the appropriate chunk node.
	if not _chunk_node:
		var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
		if not get_tree().current_scene is Location:
			push_error("Unable to spawn item if not on a map")
			return
		var chunk_node_name = WorldContext.get_chunk_node_name(chunk_coord)
		var location = get_tree().current_scene
		chunk_node = location.get_node_or_null(chunk_node_name) #.find_child(chunk_node_name)
	else:
		chunk_node = _chunk_node
		
	if chunk_node == null:
		push_error("Unable to spawn an item: chunk node not found")
		return
	
	# Defer adding the pickup to the scene.
	chunk_node.add_child.call_deferred(pickup)
	pickup.set_deferred("global_position", global_position)
	current_map.add_item_pickup(pickup)


# Function for spawning an item from direct parameters.
func spawn_item_at(item: Item, global_position: Vector2, amount: int = 1) -> void:
	_spawn_item_internal(item, global_position, amount)


# Function for spawning an item from persisted data.
func spawn_item_from_persistance(persistance: PersistanceItemPickupState) -> void:
	if not ItemContext.item_path_lookup.has(persistance.item_key):
		push_error("Item key '%s' not found in lookup" % persistance.item_key)
		return
	var item: Item = load(ItemContext.item_path_lookup[persistance.item_key])
	_spawn_item_internal(item, persistance.position, persistance.amount, null, persistance)

func spawn_item_from_persistance_with_chunk(persistance: PersistanceItemPickupState, chunk_node: Node2D) -> void:
	if not ItemContext.item_path_lookup.has(persistance.item_key):
		push_error("Item key '%s' not found in lookup" % persistance.item_key)
		return
	var item: Item = load(ItemContext.item_path_lookup[persistance.item_key])
	_spawn_item_internal(item, persistance.position, persistance.amount, chunk_node, persistance)

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
		if not ItemContext.item_path_lookup.has(item_key):
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
