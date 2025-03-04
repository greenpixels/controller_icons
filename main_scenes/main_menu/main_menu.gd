extends Control

@onready var character_select := preload("res://main_scenes/player_select/player_select.tscn")

func _ready() -> void:
	pass

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(character_select)


func _on_options_button_pressed() -> void:
	OptionsContext._toggle_menu()


func _on_exit_button_pressed() -> void:
	await get_tree().process_frame
	get_tree().quit.call_deferred()
