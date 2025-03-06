extends Control

@onready var name_input : OnScreenKeyboard = %NameInput
var player_name := ""

func _ready() -> void:
	name_input.on_text_changed.connect(func(text):
		player_name = text
		%CreateButton.disabled = player_name.length() < 3
	)

func _on_create_button_pressed() -> void:
	var new_player = PersistancePlayerState.new()
	new_player.name = player_name
	new_player.add_item("WOODEN_PICKAXE", 1)
	new_player.add_item("ITEM_OMINOUS_CAP", 1)
	new_player.save_to_disk()
	get_tree().change_scene_to_packed(load("res://main_scenes/player_select/player_select.tscn"))
