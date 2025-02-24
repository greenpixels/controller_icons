extends Node

var players : Array[Player]
var player_scene := preload("res://object_scenes/player/player.tscn")
var camera_scene := preload("res://object_scenes/main_camera/main_camera.tscn")


signal players_changed

func _ready() -> void:
	add_new_player(0)

func check_player_exists(player_index: int):
	for existing_player in players:
		if existing_player.player_index == player_index:
			return true
	return false

func remove_player(player_index: int):
		var player : Player
		for existing_player in players:
			if existing_player.player_index == player_index:
				player = existing_player
				break
		if player == null: 
			push_error("Player with index " + str(player_index) + " does not exist")
			return
		
		var parent = player.get_parent()
		parent.remove_child(player)
		players.remove_at(players.find(player))
		print("Removed player with index " + str(player_index))
		players_changed.emit()

func add_new_player(player_index : int):
	if check_player_exists(player_index):
		push_error("Player " + str(player_index) + " already exists")
		return
	var player : Player = player_scene.instantiate()
	player.player_index = player_index
	if player_index == 0:
		player.add_child(camera_scene.instantiate())
	player.controller = InputContext.input_controllers[player_index]	
	
	# Add player to the same parent as the main player
	if players.size() > 0:
		var main_player_parent = players[0].get_parent()
		if main_player_parent:
			main_player_parent.add_child(player)
			player.position = players[0].position
	print("Added a new player with device " + str(player_index) + "!")
	players.push_back(player)
	players_changed.emit()
	
func spawn_players_at(node: Node, position: Vector2 = Vector2.ZERO):
	for player in players:
		node.add_child(player)
		player.position = position

func withdraw_players_from_scene():
	for player in players:
		var parent = player.get_parent()
		parent.remove_child(player)
