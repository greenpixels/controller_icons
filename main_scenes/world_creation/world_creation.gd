extends Control

@onready var name_input : OnScreenKeyboard = %NameInput
@onready var seed_input : OnScreenKeyboard = %SeedInput

var world_name := ""
var world_seed := ""

func _ready() -> void:
	name_input.on_text_changed.connect(func(text):
		world_name = text
		handle_input_change()
	)
	seed_input.on_text_changed.connect(func(text):
		world_seed = text
		handle_input_change()
	)
	handle_input_change()

func handle_input_change():
	%CreateButton.disabled = world_name.length() < 3 or world_seed.length() <= 0

func _on_create_button_pressed() -> void:
	var new_world = PersistanceWorldState.new()
	new_world.name = world_name
	new_world.original_seed_text = world_seed
	new_world.main_seed = hash(world_seed)
	new_world.save_to_disk()
	get_tree().change_scene_to_packed(load("res://main_scenes/world_select/world_select.tscn"))
