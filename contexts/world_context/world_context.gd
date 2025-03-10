extends Node
const BLOCK_PADDING := Vector2i(6, 6)
const BLOCK_SIZE := Vector2i(192, 156)
const CHUNK_SIZE := Vector2i(15, 15)
const CHUNK_OFFSET := Vector2i(CHUNK_SIZE) / 2
const DEFAULT_OVERWORLD_MAP_UUID := "main"

var world_state : PersistanceWorldState
var current_map_uuid_stack : Array[String] = [DEFAULT_OVERWORLD_MAP_UUID]

func _ready() -> void:
	randomize()

func reset():
	world_state = null
	current_map_uuid_stack = [DEFAULT_OVERWORLD_MAP_UUID]

func get_chunk_node_name(chunk_coord: Vector2i):
	return "Chunk_%d_%d" % [chunk_coord.x, chunk_coord.y]

func calculate_base_chunk_coordinate(position: Vector2i) -> Vector2i:
	var grid_pos = round(Vector2(position) / Vector2(BLOCK_SIZE + BLOCK_PADDING) + Vector2(CHUNK_OFFSET)) 
	var chunk_x_float = float(grid_pos.x)  / float(CHUNK_SIZE.x)
	var chunk_y_float = float(grid_pos.y)  / float(CHUNK_SIZE.y)
	return Vector2i(
		floor(chunk_x_float) if chunk_x_float < 0 else floor(chunk_x_float),
		floor(chunk_y_float) if chunk_y_float < 0 else floor(chunk_y_float)
	)

func _enter_tree() -> void:
	world_state = PersistanceWorldState.new()

func get_current_map() -> PersistanceMapState:
	return world_state.get_map(current_map_uuid_stack.back())
	
func enter_cave(block: Block, location_key: String):
	if block.uuid.is_empty():
		printerr("Block UUID empty is not allowed to be empty")
	var sum_ab = block.global_position.x + block.global_position.y
	world_state.current_sub_seed = int(world_state.main_seed + int((sum_ab * (sum_ab + 1)) / 2.) + block.global_position.y)
	
	_change_location(location_key, func():
		PlayersContext.withdraw_players_from_scene()
		WorldContext.current_map_uuid_stack.push_back(block.uuid)
	)
	
func leave_cave():
	if current_map_uuid_stack.size() < 2: return
	_change_location(
		world_state.get_map(current_map_uuid_stack[current_map_uuid_stack.size() - 2]).location_key,
		func():
			PlayersContext.withdraw_players_from_scene()
			WorldContext.current_map_uuid_stack.pop_back()
	)
	
func _change_location(location_key: String, before_change: Callable):
	var location_path = LocationMappings.key_to_path[location_key]
	var location_scene = load(location_path)
	if location_scene:
		TransitionHandler.transition_to(location_scene, 0.85, TransitionHandler.TransitionType.DONUT, before_change)
	else:
		push_error("Unable to find location scene")
		TransitionHandler.transition_to(load(LocationMappings.LOCATION_OVERWORLD), 0.85, TransitionHandler.TransitionType.DONUT, before_change)
		#get_tree().change_scene_to_packed()
