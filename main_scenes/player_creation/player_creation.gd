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
	new_player.inventory.push_back(load("res://resources/items/weapons/tools/_all/wooden_pickaxe.tres").key)
	new_player.inventory_quantities.push_back(1)
	new_player.save_to_disk()
	get_tree().change_scene_to_packed(load("res://main_scenes/player_select/player_select.tscn"))
