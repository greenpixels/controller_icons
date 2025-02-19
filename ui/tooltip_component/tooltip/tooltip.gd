extends PanelContainer
class_name Tooltip

@onready var description_label_rich_text : RichTextLabel = $MarginContainer/PaddingContainer/RichTextLabel

func set_description(content: String):
	description_label_rich_text.text = content
