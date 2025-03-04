extends Control

var world_creation_scene := preload("res://main_scenes/world_creation/world_creation.tscn")
var world_select_entry_scene := preload("res://main_scenes/world_select/world_select_entry/world_select_entry.tscn")

func _ready() -> void:
	var world_persistances = get_worlds_peristances()
	for world_persistance in world_persistances:
		var entry := world_select_entry_scene.instantiate()
		entry.world_name = world_persistance.name
		entry.world_seed = world_persistance.original_seed_text + " ({seed_value})".format({"seed_value": world_persistance.main_seed})
		entry.on_select.connect(func():_on_world_select(world_persistance))
		entry.on_delete.connect(func():_on_world_delete(world_persistance))
		%WorldList.add_child(entry)

func _on_world_select(persistance: PersistanceWorldState):
	WorldContext.world_state = persistance
	get_tree().change_scene_to_packed(load("res://main_scenes/locations/_all/overworld/overworld.tscn"))

func get_worlds_peristances():
	var world_persistances : Array[PersistanceWorldState]= []
	var dir = DirAccess.open(PersistanceWorldState.WORLD_SAVE_BASE_PATH)
	if not dir:
		dir = DirAccess.open("user://")
		if dir:
			dir.make_dir_recursive(PersistanceWorldState.WORLD_SAVE_BASE_PATH)
		else:
			print("Failed to open directory")
			return world_persistances
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var world_persistance = load(PersistanceWorldState.WORLD_SAVE_BASE_PATH + file_name)
			if world_persistance is not PersistanceWorldState: continue
			world_persistances.append(world_persistance)
		file_name = dir.get_next()
	dir.list_dir_end()
	return world_persistances

func _on_new_world_button_pressed() -> void:
	get_tree().change_scene_to_packed(world_creation_scene)

func _on_world_delete(persistance: PersistanceWorldState):
	var dir = DirAccess.open(PersistanceWorldState.WORLD_SAVE_BASE_PATH)
	if not dir:
		dir = DirAccess.open("user://")
		if dir:
			dir.make_dir_recursive(PersistanceWorldState.WORLD_SAVE_BASE_PATH)
		else:
			print("Failed to open directory")
			return
	dir.remove(persistance.uuid + ".tres")
	get_tree().reload_current_scene()
