extends Node

@export var cave_scene : PackedScene

func _on_interact_area_interacted() -> void:
	var parent : Block = get_parent()
	WorldContext.enter_cave(parent, "LOCATION_IRON_CAVE")
