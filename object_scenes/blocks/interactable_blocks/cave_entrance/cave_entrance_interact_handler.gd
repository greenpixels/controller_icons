extends Node

func _on_interact_area_interacted() -> void:
	var parent : Block = get_parent()
	WorldContext.enter_cave(parent, "LOCATION_IRON_CAVE")
