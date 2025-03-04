extends Control

var player_select_entry_scene := preload("res://main_scenes/player_select/player_select_entry/player_select_entry.tscn")
var character_creation_scene := preload("res://main_scenes/player_creation/player_creation.tscn")
var world_select_scene := preload("res://main_scenes/world_select/world_select.tscn")

func _ready() -> void:
	var player_persistances = get_player_peristances()
	for player_persistance in player_persistances:
		var entry := player_select_entry_scene.instantiate()
		entry.player_name = player_persistance.name
		%PlayerList.add_child(entry)
		entry.on_select.connect(func(): _on_player_select(player_persistance))
		entry.on_delete.connect(func(): _on_player_delete(player_persistance))

func _on_player_select(persistance: PersistancePlayerState):
	if not PlayersContext.players.size() > 0:
		PlayersContext.add_new_player(0, persistance)
	if not PlayersContext.players.size() > 0:
		push_error("Unable to select player")
		return
	get_tree().change_scene_to_packed(world_select_scene)

func _on_new_character_button_pressed() -> void:
	get_tree().change_scene_to_packed(character_creation_scene)


func get_player_peristances() -> Array[PersistancePlayerState]:
	var player_persistances : Array[PersistancePlayerState]= []
	var dir = DirAccess.open(PersistancePlayerState.PLAYER_SAVE_BASE_PATH)
	if not dir:
		dir = DirAccess.open("user://")
		if dir:
			dir.make_dir_recursive(PersistancePlayerState.PLAYER_SAVE_BASE_PATH)
		else:
			print("Failed to open directory")
			return player_persistances
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(GameSettings.RESOURCE_SAVE_FILE_EXTENSTION):
			var player_persistance = load(PersistancePlayerState.PLAYER_SAVE_BASE_PATH + file_name)
			if player_persistance is not PersistancePlayerState: continue
			player_persistances.append(player_persistance)
		file_name = dir.get_next()
	dir.list_dir_end()
	return player_persistances


func _on_player_delete(persistance: PersistancePlayerState):
	var dir = DirAccess.open(PersistancePlayerState.PLAYER_SAVE_BASE_PATH)
	if not dir:
		dir = DirAccess.open("user://")
		if dir:
			dir.make_dir_recursive(PersistancePlayerState.PLAYER_SAVE_BASE_PATH)
		else:
			print("Failed to open directory")
			return
	dir.remove(persistance.uuid + GameSettings.RESOURCE_SAVE_FILE_EXTENSTION)
	get_tree().reload_current_scene()
