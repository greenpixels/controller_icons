@tool
extends Mapper

func _run():
	map_and_save("ModelTextureMappings", "res://_assets/model_textures/", "res://mappers/model_textures/model_texture_mappings.gd", ".png")
