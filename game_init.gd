extends Node

func _ready() -> void:
	LimboConsole.register_command(_list_all_items, "items", "List all items that are currently loaded")
	LimboConsole.register_command(_spawn_item, "item", "Spawns an item at the position of the first player")
	LimboConsole.register_command(_spawn_random_npc, "npc", "Spawns a random NPC at the position of the first player")
	LimboConsole.register_command(_toggle_chunk_debug, "DEBUG_chunk", "Toggle debugging for chunks")
	LimboConsole.register_command(_toggle_camera_detach, "toggle_camera", "Toggles camera following the player on or off.")
	LimboConsole.register_command(_set_camera_zoom, "zoom", "Sets the camera zoom. Automatically detached the camera.")
	LimboConsole.register_command(_start_slow_camera_zoom_out, "start_cinematic_zoom_out", "Slowly zooms the camera out over a period of 20 seconds")
	LimboConsole.register_command(_sonic, "sonic", "Go fast as f*ck")

func _start_slow_camera_zoom_out():
	MainCamera.target_zoom_overwrite = 0.6
	var tween = TweenHelper.tween("camera_zoom_out", self)
	tween.tween_property(MainCamera, "target_zoom_overwrite", 0.1, 20).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(MainCamera, "target_zoom_overwrite", 1, 10).set_trans(Tween.TRANS_LINEAR).set_delay(6)

func _sonic():
	MainCamera.target_zoom_overwrite = 1.0
	var tween = TweenHelper.tween("camera_zoom_out", self)
	tween.tween_property(MainCamera, "target_zoom_overwrite", 0.1, 5).set_trans(Tween.TRANS_LINEAR)
	
	for player in PlayersContext.players:
		var speed_tween = TweenHelper.tween("player_speed_up", player)
		player.base_speed = 500
		speed_tween.tween_property(player, "base_speed", 20000, 10).set_trans(Tween.TRANS_EXPO)

func _toggle_camera_detach():
	MainCamera.detached = !MainCamera.detached
	#MainCamera.target_zoom_overwrite = 1.0

func _set_camera_zoom(value: float):
	#MainCamera.detached = true
	MainCamera.target_zoom_overwrite = value

func _list_all_items(search: String = ""):
	var found_match = false
	for key in ItemContext.item_path_lookup.keys() as Array[String]:
		if key.contains(search.to_upper()) or search.is_empty():
			LimboConsole.info(key)
			found_match = true
	if not found_match:
		LimboConsole.error("No match was found.")

func _spawn_item(item_key : String, amount: int = 1):
	if not ItemContext.item_path_lookup.has(item_key):
		LimboConsole.error("Item '{key}' does not exist".format({"key": item_key}))
		return
	if PlayersContext.players.size() > 0 and PlayersContext.players[0].is_visible_in_tree():
		ItemContext.spawn_item_at(load(ItemContext.item_path_lookup[item_key]), PlayersContext.players[0].global_position, amount)
		LimboConsole.info("Spawned item {amount}x '{key}'".format({"amount": amount, "key": item_key}))
	else:
		LimboConsole.error("Unable to spawn items if there aren't any players")

func _spawn_random_npc(amount: int = 1):
	if PlayersContext.players.size() > 0 and PlayersContext.players[0].is_visible_in_tree():
		for index in range(amount):
			NpcContext.spawn_random_npc(PlayersContext.players[0].global_position)
		LimboConsole.info("Spawned {amount}x NPC".format({"amount": amount}))
	else:
		LimboConsole.error("Unable to spawn items if there aren't any players")

func _toggle_chunk_debug():
	MapGenerator.chunk_debug_mode = !MapGenerator.chunk_debug_mode
	if MapGenerator.chunk_debug_mode:
		LimboConsole.info("Activated chunk debugging")
	else:
		LimboConsole.info("Deactivated chunk debugging")
