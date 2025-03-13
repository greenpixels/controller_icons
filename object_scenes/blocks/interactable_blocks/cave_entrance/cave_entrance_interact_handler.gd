extends Node

@export var location_key : String

func _on_interact_area_interacted() -> void:
	var parent : Block = get_parent()
	WorldContext.enter_cave(parent, location_key)
