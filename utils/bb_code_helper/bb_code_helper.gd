## A utility class for building and formatting BBCode strings.
##
## This class provides methods to manipulate and style text using BBCode, such as
## adding colors, icons, and centering text dynamically.
class_name BBCodeHelper

## The BBCode content being built.
var content: String = ""

## A placeholder texture used for spacing adjustments in icon additions.
var empty_image: Texture = preload("res://utils/bb_code_helper/empty.png")

## Creates a new instance of `BBCodeHelper` with the provided content.
##
## @param _content The initial BBCode content.
## @returns A new `BBCodeHelper` instance with the given content.
static func build(_content: String) -> BBCodeHelper:
	var instance = BBCodeHelper.new()
	instance.content = _content
	return instance

## Wraps the content in a BBCode color tag.
##
## @param hex The color in hex format (e.g., "#FF0000" for red).
## @returns The updated `BBCodeHelper` instance.
func set_color(hex: String) -> BBCodeHelper:
	content = "[color={hex}]{content}[/color]".format({"hex": hex, "content": content})
	return self

## Adds an icon before or after the current content.
##
## The icon is resized to match the specified height while maintaining its aspect ratio.
##
## @param texture The texture to be used as an icon.
## @param size The height of the icon in pixels (default: 21).
## @param before If `true`, the icon is placed before the content; otherwise, it's placed after.
## @returns The updated `BBCodeHelper` instance.
func add_icon(texture: Texture, size: int = 21, before = true) -> BBCodeHelper:
	var width = (texture.get_width() / texture.get_height()) * size
	var empty_image_string = "[img=4x{size_y}]{empty_path}[/img]".format({"empty_path": empty_image.resource_path, "size_y": size})
	var image_string = "[img={size_x}x{size_y}]{path}[/img]".format({
		"path": texture.resource_path,
		"size_x": width,
		"size_y": size
		})
	content = image_string + empty_image_string + content if before else content + empty_image_string + image_string
	return self

## Replaces a given key in the content with a colored numerical value.
##
## This is useful for dynamically updating text with numbers that should be highlighted.
##
## @param key The placeholder key in the content to replace.
## @param value The numerical value to insert.
## @param color The color in which the number should be displayed.
## @param add_sign If `true`, adds a `+` sign before positive numbers.
## @returns The updated `BBCodeHelper` instance.
func replace_key_as_coloured_number_value(key: String, value: float, color: String, add_sign = false) -> BBCodeHelper:
	var number_sign = ""
	if add_sign: number_sign = "+" if value > 0 else ""
	content = content.format({key: BBCodeHelper.build(number_sign + str(value)).set_color(color).result()})
	return self

## Centers the content using BBCode.
##
## @returns The updated `BBCodeHelper` instance.
func center() -> BBCodeHelper:
	content = "[center]{content}[/center]".format({"content": content})
	return self

## Returns the final BBCode-formatted string.
##
## @returns The formatted BBCode string.
func result():
	return content
