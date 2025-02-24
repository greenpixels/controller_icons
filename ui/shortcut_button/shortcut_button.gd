extends PanelContainer

@export var label_text := "[center]Button"
@export var shortcut_actions := ["none"]
@onready var shortcut_icon : TextureRect = %IconTexture
@onready var text_label : RichTextLabel = %LabelText
signal pressed

func _ready() -> void:
	text_label.text = "[center]" + label_text
	var shortcut = Shortcut.new()
	var index := 0
	for shortcut_action in shortcut_actions:
		if index == 0:
			var controller_texture_icon = ControllerIconTexture.new()
			controller_texture_icon.path = shortcut_action
			shortcut_icon.texture = controller_texture_icon
		var input_action := InputEventAction.new()
		input_action.action = shortcut_action
		shortcut.events.push_back(input_action)
		index += 1
	%Button.shortcut = shortcut

func _process(delta: float) -> void:
	shortcut_icon.size.y = 50

func _on_button_pressed() -> void:
	pressed.emit()
