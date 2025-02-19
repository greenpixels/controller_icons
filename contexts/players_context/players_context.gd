extends Node

var players : Array[Player]
var player_scene := preload("res://object_scenes/player/player.tscn")
var camera_scene := preload("res://object_scenes/main_camera/main_camera.tscn")

func _process(_delta: float) -> void:
	for device_index in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(device_index, JOY_BUTTON_START):
			add_new_player(device_index)

func _ready() -> void:
	add_new_player(0) # The main player always maps to the first device
	Input.joy_connection_changed.connect(func(device_index, _is_connected):
		if !is_connected:
			if device_index != 0:
				handle_joy_disconnect(device_index)
			else:
				print("Can not remove player 0")
			
	)
	
func handle_joy_disconnect(device_index: int):
	for player in players:
		if player.device_index == device_index:
			print("Removed player with index " + str(device_index))
			var parent = player.get_parent()
			parent.remove_child(player)

func add_new_player(device_index : int):
	if players.any(func(existing_player): return existing_player.device_index == device_index):
		print("Player is already connected with " + str(device_index))
		return
	
	
	var player : Player = player_scene.instantiate()
	if device_index == 0:
		player.add_child(camera_scene.instantiate())
	player.device_index = device_index
	
	# Add player to the same parent as the main player
	if players.size() > 0:
		var main_player_parent = players[0].get_parent()
		if main_player_parent:
			main_player_parent.add_child(player)
			player.position = players[0].position
	print("Added a new player with device " + str(device_index) + "!")
	players.push_back(player)
	
func spawn_players_at(node: Node, position: Vector2 = Vector2.ZERO):
	for player in players:
		node.add_child(player)
		player.position = position

func remove_players():
	for player in players:
		var parent = player.get_parent()
		parent.remove_child(player)
