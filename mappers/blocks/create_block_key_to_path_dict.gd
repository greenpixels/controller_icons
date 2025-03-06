@tool
extends Mapper

func _run():
	map_and_save("BlockMappings", "res://object_scenes/blocks/", "res://mappers/blocks/block_mappings.gd")
