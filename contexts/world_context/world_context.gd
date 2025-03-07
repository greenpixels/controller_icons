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
	var grid_pos = (position + BLOCK_SIZE / 2 - BLOCK_SIZE) / (BLOCK_SIZE + BLOCK_PADDING) - CHUNK_OFFSET
	return Vector2i(
		round( (float(grid_pos.x) + float(CHUNK_SIZE.x)/2.) / float(CHUNK_SIZE.x)),
		round( (float(grid_pos.y) + float(CHUNK_SIZE.y)/2.) / float(CHUNK_SIZE.y)),
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
	PlayersContext.withdraw_players_from_scene()
	current_map_uuid_stack.push_back(block.uuid)
	_change_location(location_key)
	
func leave_cave():
	PlayersContext.withdraw_players_from_scene()
	current_map_uuid_stack.pop_back()
	_change_location(get_current_map().location_key)
	
func _change_location(location_key: String):
	var location_path = LocationMappings.key_to_path[location_key]
	var location_scene = load(location_path)
	if location_scene:
		get_tree().change_scene_to_packed(location_scene)
	else:
		push_error("Unable to find location scene")
		get_tree().change_scene_to_packed(load(LocationMappings.LOCATION_OVERWORLD))
