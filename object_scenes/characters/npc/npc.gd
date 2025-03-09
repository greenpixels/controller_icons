extends CharacterBase
class_name Npc

func _on_moved(_position: Vector2) -> void:
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
	if str(chunk_coord) != persistance.chunk_key:
		if WorldContext.get_current_map().chunks.has(str(chunk_coord)):
			WorldContext.get_current_map().remove_npc(self)
			print("Removed NPC from " + persistance.chunk_key)
			print("Added NPC to " + str(chunk_coord))
			WorldContext.get_current_map().chunks[str(chunk_coord)].npcs[persistance.uuid] = persistance
			persistance.chunk_key = str(chunk_coord)
		else:
			queue_free()
	persistance.position = global_position


func _on_node_state_changed(state: HumanNpcController.State) -> void:
	%StateLabel.text = HumanNpcController.State.keys()[state]
			
