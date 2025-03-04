@tool
extends PanelContainer

signal on_select
signal on_delete

@export var player_name := "Player Name" : 
	set(value):
		if not is_node_ready():
			await ready
		player_name = value
		%NameLabel.text = player_name

func _on_select_button_pressed() -> void:
	on_select.emit()


func _on_delete_button_pressed() -> void:
	on_delete.emit()
