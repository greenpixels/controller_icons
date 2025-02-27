extends Node


func _on_interact_area_interacted() -> void:
	PlayersContext.withdraw_players_from_scene()
	get_tree().change_scene_to_packed(load("res://main_scenes/locations/overworld/overworld.tscn"))
