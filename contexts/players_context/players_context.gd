extends Node

var player_scene := preload("res://object_scenes/characters/player/player.tscn")
var camera_scene := preload("res://object_scenes/main_camera/main_camera.tscn")

var players: Array[Player] = []
var players_interact_focus: Array[InteractArea] = []

signal players_spawned
signal players_despawned
signal players_changed
signal players_interact_focus_changed

func get_player_by_index(player_index: int) -> Player:
	for player in players:
		if player.player_index == player_index:
			return player
	return null

func player_exists(player_index: int) -> bool:
	return get_player_by_index(player_index) != null

func remove_player(player_index: int) -> void:
	var player: Player = get_player_by_index(player_index)
	if player == null:
		push_error("Player with index " + str(player_index) + " does not exist")
		return
	players_interact_focus.remove_at(player_index)
	player.get_parent().remove_child(player)
	players.erase(player)
	print("Removed player with index " + str(player_index))
	players_changed.emit()

func add_new_player(player_index: int, persistance : PersistancePlayerState) -> void:
	if player_exists(player_index):
		push_error("Player " + str(player_index) + " already exists")
		return
	var player: Player = player_scene.instantiate()
	player.player_index = player_index
	player.controller = InputContext.input_controllers[player_index]
	if players.size() > 0:
		var main_player_parent = players[0].get_parent()
		if main_player_parent:
			main_player_parent.add_child(player)
			player.position = players[0].position
	player.persistance = persistance
	print("Added a new player with device " + str(player_index) + "!")
	players.push_back(player)
	players_interact_focus.push_back(null)
	players_interact_focus_changed.emit()
	players_changed.emit()

func spawn_players_at(parent_node: Node, position = null) -> void:
	if position == null:
		if not WorldContext.get_current_map() == null and "last_player_position" in WorldContext.get_current_map():
			position = WorldContext.get_current_map().last_player_position
		else:
			position = Vector2.ZERO
	players_interact_focus= []
	
	for player in players:
		players_interact_focus.push_back(null)
		parent_node.add_child(player)
		player.position = position
	var camera = camera_scene.instantiate()
	camera.position = position
	parent_node.add_child(camera)
	players_interact_focus_changed.emit()
	players_spawned.emit()

func withdraw_players_from_scene() -> void:
	if PlayersContext.players.size() > 0:
		WorldContext.get_current_map().last_player_position = PlayersContext.players[0].position
	for player in players:
		if player.is_visible_in_tree():
			player.get_parent().remove_child(player)
	players_despawned.emit()
