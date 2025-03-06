extends Resource
class_name ModelPartConfiguration

@export_color_no_alpha var color: Color = Color.WHITE
@export var texture: Texture2D = null

static func init(_texture: Texture2D, _color: Color) -> ModelPartConfiguration:
	var config = ModelPartConfiguration.new()
	config.color = _color
	config.texture = _texture
	return config
