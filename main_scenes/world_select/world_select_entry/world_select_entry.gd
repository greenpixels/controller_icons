@tool
extends PanelContainer

signal on_select
signal on_delete

@export var world_name := "World Name" : 
	set(value):
		if not is_node_ready():
			await ready
		world_name = value
		%NameLabel.text = world_name


@export var world_seed:= "World Seed" : 
	set(value):
		if not is_node_ready():
			await ready
		world_seed = value
		%SeedLabel.text = world_seed

func _on_select_button_pressed() -> void:
	on_select.emit()


func _on_delete_button_pressed() -> void:
	on_delete.emit()
