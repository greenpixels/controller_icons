extends Node

@onready var human_npc_scene := preload("res://object_scenes/characters/npc/_all/human/human.tscn")

func spawn_random_npc(global_position: Vector2, _chunk_node: Node2D = null) -> void:
	var npc : CharacterBase = human_npc_scene.instantiate()
	npc.persistance = PersistanceNpcState.new()
	npc.persistance.position = global_position
	npc.persistance.add_item("ITEM_WOODEN_PICKAXE", 1)
	npc.persistance.equip_item("ITEM_OMINOUS_CAP", PlayerInventory.ArmorSlotPositions.HELMET)

	
	var chunk_node: Node2D
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
	npc.persistance.chunk_key = str(chunk_coord)
	# Determine the appropriate chunk node.
	if not _chunk_node:
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
	persist_npc.call_deferred(str(chunk_coord), npc)
	chunk_node.add_child.call_deferred(npc)
	npc.set_deferred("global_position", global_position)
	# current_map.add_item_pickup(pickup)

func persist_npc(chunk_coord : String, npc: Npc):
	var current_map = WorldContext.get_current_map()
	current_map.chunks[str(chunk_coord)].npcs[npc.persistance.uuid] = npc.persistance

func spawn_npc_from_persistance(persistance: PersistanceNpcState, _chunk_node: Node2D = null) -> void:
	var npc : CharacterBase = human_npc_scene.instantiate()
	npc.persistance = persistance
	_chunk_node.add_child.call_deferred(npc)
	npc.set_deferred("global_position", npc.persistance.position)
	
