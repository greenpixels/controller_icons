extends Node


func _on_interact_area_interacted() -> void:
	WorldContext.leave_cave()
