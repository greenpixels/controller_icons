@tool
extends Mapper

func _run():
	map_and_save("LocationMappings", "res://main_scenes/locations/", "res://mappers/locations/location_mappings.gd")
