extends Node

@export var cave_scene : PackedScene

func _on_interact_area_interacted() -> void:
	PlayersContext.withdraw_players_from_scene()
	WorldContext.set_sub_seed_by_block(get_parent())
	get_tree().change_scene_to_packed(cave_scene)
	
