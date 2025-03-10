extends Node2D
class_name MapGenerator

var chunk_scene := preload("res://object_scenes/map_generator/chunk/chunk.tscn")

var dirt_block := preload("res://object_scenes/blocks/_all/dirt/block_dirt.tscn")
var boundary_block := preload("res://object_scenes/blocks/_all/boundary/block_boundary.tscn")
var spawn_point := Vector2(0, 0)
var block_padding = WorldContext.BLOCK_PADDING
var block_size = WorldContext.BLOCK_SIZE
var chunk_size = WorldContext.CHUNK_SIZE
var chunk_offset = WorldContext.CHUNK_OFFSET 
var noise: FastNoiseLite
var generated_chunks := {}
var uuid : String
var source_geometry_data := NavigationMeshSourceGeometryData2D.new()
var chunk_size_px = Vector2(chunk_size * (block_size + block_padding))
var agent_radius = 54.0
var adjusted_chunk_size_px = chunk_size_px + Vector2(agent_radius * 2, agent_radius * 2)
var chunk_polygon_points := PackedVector2Array([
		Vector2(0, 0),
		Vector2(adjusted_chunk_size_px.x, 0),
		adjusted_chunk_size_px,
		Vector2(0, adjusted_chunk_size_px.y)
	])
static var chunk_debug_mode := false

@export var spawn_point_empty_padding := Vector2(2, 2)
@export var empty_area_threshold: float = -0.08
@export var noise_frequency: float = 0.1
@export var max_map_size_in_blocks := 0
@export var use_sub_seed := true
@export var loading_triggers: Array[Node2D] = []
@export var block_types: Array[BlockSpawnConfiguration] = []
var map : PersistanceMapState
var parent_node: Node = null
var chunk_node_positions : Array[Vector2] = []

func _ready() -> void:
	parent_node = get_parent()
	uuid = WorldContext.current_map_uuid_stack.back()
	map = WorldContext.world_state.get_map(uuid)
	if map == null:
		if not parent_node is Location: return
		var persistance = PersistanceMapState.new()
		persistance.init(uuid, parent_node)
		WorldContext.world_state.set_map(persistance)
		map = WorldContext.world_state.get_map(uuid)
	_initialize_noise()
	_connect_players_to_chunk_updates()
	update_chunks()

func _initialize_noise() -> void:
	seed(WorldContext.world_state.main_seed if not use_sub_seed else WorldContext.world_state.current_sub_seed)
	noise = FastNoiseLite.new()
	noise.seed = WorldContext.world_state.main_seed if not use_sub_seed else WorldContext.world_state.current_sub_seed
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
	noise.frequency = noise_frequency

func _connect_players_to_chunk_updates() -> void:
	for player in PlayersContext.players:
		_connect_player_to_chunk_updates(player)
	PlayersContext.players_spawned.connect(func():
		update_chunks()
		_on_players_changed()
	)

func _connect_player_to_chunk_updates(player: Node2D) -> void:
	if not loading_triggers.has(player):
		player.moved.connect(func(_position):
			update_chunks()
		)
		loading_triggers.push_back(player)

func _on_players_changed() -> void:
	for player in PlayersContext.players:
		_connect_player_to_chunk_updates(player)

# Generates a chunk at the given chunk coordinate (each chunk is chunk_size blocks in width and height)
func generate_chunk(chunk_coord: Vector2i) -> void:
	var chunk_coord_string = str(chunk_coord)
	var chunk_node = _create_chunk_node(chunk_coord)
	_seed_chunk(chunk_coord)
	generated_chunks[chunk_coord_string] = chunk_node
	if not map.chunks.has(chunk_coord_string):
		var persistance = PersistanceChunkInformation.new()
		persistance.init(chunk_coord_string)
		map.chunks[chunk_coord_string] = persistance
		_generate_blocks_in_chunk(chunk_coord, chunk_node, chunk_coord_string)
	else:
		_load_blocks_from_persisted_chunk(chunk_node, chunk_coord_string)
		_load_item_pickups_from_persisted_chunk(chunk_node, chunk_coord_string)
		_load_npcs_from_persisted_chunk(chunk_node, chunk_coord_string)
	
	#await get_tree().physics_frame
	_create_chunk_navigation_region(chunk_node)
	chunk_node.child_exiting_tree.connect(_handle_block_change)
	chunk_node.child_entered_tree.connect.call_deferred(_handle_block_change)
	

func _handle_block_change(block: Node):
	if not is_instance_valid(block): return
	if not block is Block: return
	var chunk_node = block.get_parent()
	_create_chunk_navigation_region(chunk_node)

func _load_npcs_from_persisted_chunk(chunk_node: Node, chunk_coord_string):
	var map_chunk_npcs = map.chunks[chunk_coord_string].npcs
	for npc_uuid in map_chunk_npcs.keys():
		var npc_persistance = map_chunk_npcs[npc_uuid]
		if npc_persistance is PersistanceCharacterState:
			NpcContext.spawn_npc_from_persistance(npc_persistance, chunk_node)

func _load_item_pickups_from_persisted_chunk(chunk_node: Node, chunk_coord_string):
	var map_chunk_item_pickups = map.chunks[chunk_coord_string].item_pickups
	for item_pickup_uuid in map_chunk_item_pickups.keys():
		var item_pickup_persistance = map_chunk_item_pickups[item_pickup_uuid]
		if not ItemContext.item_path_lookup.has(item_pickup_persistance.item_key):
			continue
		var item : Item = load(ItemContext.item_path_lookup[item_pickup_persistance.item_key])
		if not item is Item: continue
		if item_pickup_persistance is PersistanceItemPickupState:
			ItemContext.spawn_item_from_persistance_with_chunk(item_pickup_persistance, chunk_node)
		
func _seed_chunk(chunk_coord: Vector2) -> void:
	var sum_ab = _calculate_sum_ab(chunk_coord)
	var seed_value = _calculate_seed_value(sum_ab, int(chunk_coord.y))
	seed(seed_value)

func _calculate_sum_ab(chunk_coord: Vector2) -> int:
	return int(chunk_coord.x) + int(chunk_coord.y)

func _calculate_seed_value(sum_ab: int, y: int) -> int:
	var base_seed = WorldContext.world_state.main_seed if not use_sub_seed else WorldContext.world_state.current_sub_seed
	return base_seed + int((sum_ab * (sum_ab + 1)) / 2.) + y

func _create_chunk_node(chunk_coord: Vector2) -> Node2D:
	var chunk_node = chunk_scene.instantiate()
	chunk_node.global_position = chunk_coord *  Vector2(block_size + block_padding) * Vector2(chunk_size) - Vector2(block_size + block_padding) * Vector2(chunk_offset) - Vector2(block_size)/2.
	chunk_node_positions.push_back(chunk_node.global_position)
	chunk_node.name = WorldContext.get_chunk_node_name(chunk_coord)
	chunk_node.y_sort_enabled = true
	parent_node.add_child.call_deferred(chunk_node)
	
	return chunk_node
	
func _create_chunk_navigation_region(chunk_node: Node2D):
	await get_tree().physics_frame
	if not is_instance_valid(chunk_node): return
	var nav_polygon = _generate_navigation_polygon()
	var nav_region = _get_or_create_navigation_region(chunk_node, nav_polygon)
	_bake_navigation_polygon(nav_region, chunk_node)
	

func _generate_navigation_polygon() -> NavigationPolygon:
	var nav_polygon := NavigationPolygon.new()
	nav_polygon.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_polygon.agent_radius = agent_radius
	nav_polygon.add_outline(chunk_polygon_points)

	return nav_polygon

func _get_or_create_navigation_region(chunk_node: Node2D, nav_polygon: NavigationPolygon) -> NavigationRegion2D:
	if not is_instance_valid(chunk_node): return null
	var nav_region: NavigationRegion2D
	if chunk_node.has_node("NavigationRegion2D"):
		nav_region = chunk_node.get_node("NavigationRegion2D")
	else:
		nav_region = NavigationRegion2D.new()
		nav_region.z_as_relative = true
		nav_region.y_sort_enabled = false
		nav_region.z_index = -100
		NavigationServer2D.region_set_map(nav_region, get_world_2d().navigation_map)
		nav_region.name = "NavigationRegion2D"
		chunk_node.add_child(nav_region)

	nav_region.navigation_polygon = nav_polygon
	return nav_region

func _bake_navigation_polygon(nav_region: NavigationRegion2D, chunk_node: Node2D):
	# Wait 2 physics frames to ensure proper processing of navigation data
	if not is_inside_tree(): return
	var nav_polygon = nav_region.navigation_polygon
	NavigationServer2D.parse_source_geometry_data(nav_polygon, source_geometry_data, chunk_node)
	NavigationServer2D.bake_from_source_geometry_data(nav_polygon, source_geometry_data)
	nav_region.navigation_polygon = nav_polygon

func _load_blocks_from_persisted_chunk(chunk_node: Node2D, chunk_coord_string) -> void:
	var blocks_in_chunk = {}
	var map_chunk_blocks = map.chunks[chunk_coord_string].blocks
	
	for grid_pos_string in map_chunk_blocks.keys():
		pass
		var block_info : PersistanceBlockInformation = map_chunk_blocks[grid_pos_string]
		if blocks_in_chunk.has(grid_pos_string): continue
		var block_scene = load(BlockMappings.key_to_path[block_info.block_key])
		var block : Block = block_scene.instantiate()
		block.persistance = block_info
		block.uuid = block_info.uuid
		chunk_node.add_child.call_deferred(block)
		
		block.position = Vector2(block_info.position_in_chunk_grid) * Vector2(block_size + block_padding) - chunk_node.global_position
		_update_blocks_in_chunk(block_scene, blocks_in_chunk)
				
			
func _generate_blocks_in_chunk(chunk_coord: Vector2, chunk_node: Node2D, chunk_coord_string: String) -> void:
	var blocks_in_chunk = {}
	var map_chunk_blocks = map.chunks[chunk_coord_string].blocks
	var chunk_size_x = int(chunk_size.x)
	var chunk_size_y = int(chunk_size.y)
	for x in range(chunk_size_x):
		for y in range(chunk_size_y):
			var grid_pos = Vector2i(chunk_coord.x * chunk_size.x + x, chunk_coord.y * chunk_size.y + y) - Vector2i(chunk_offset)
			var block_scene = null;
			if _is_outside_max_map_size(grid_pos):
				block_scene = boundary_block
			elif _should_skip_block(grid_pos):
				continue
			else:
				block_scene = _choose_block_scene(grid_pos, blocks_in_chunk) as PackedScene
			_add_new_block_to_chunk(block_scene, grid_pos, chunk_node, blocks_in_chunk, map_chunk_blocks, chunk_coord_string)

func _should_skip_block(grid_pos: Vector2i) -> bool:
	return _is_within_spawn_padding(grid_pos) or _is_within_empty_area(grid_pos)

func _is_within_spawn_padding(grid_pos: Vector2i) -> bool:
	return abs(grid_pos.x - spawn_point.x) < spawn_point_empty_padding.x and abs(grid_pos.y - spawn_point.y) < spawn_point_empty_padding.y

func _is_within_empty_area(grid_pos: Vector2i) -> bool:
	return noise.get_noise_2d(grid_pos.x, grid_pos.y) < empty_area_threshold

func _is_outside_max_map_size(grid_pos: Vector2i) -> bool:
	return max_map_size_in_blocks > 0 and grid_pos.distance_to(spawn_point) > max_map_size_in_blocks

func _choose_block_scene(grid_pos: Vector2i, blocks_in_chunk: Dictionary) -> PackedScene:
	if block_types.size() > 0:
		var chosen_block = choose_block(grid_pos, blocks_in_chunk)
		if chosen_block != null:
			return chosen_block
	return dirt_block

func _add_new_block_to_chunk(block_scene: PackedScene, grid_pos: Vector2i, chunk_node: Node2D, blocks_in_chunk: Dictionary, map_chunk_blocks: Dictionary, chunk_coord_string) -> void:
	var block : Block = block_scene.instantiate()
	var grid_pos_string = str(grid_pos)
	block.position = grid_pos * (block_size + block_padding) -  Vector2i(chunk_node.global_position)
	var persistance = PersistanceBlockInformation.new()
	persistance.init(block.key, grid_pos, chunk_coord_string)
	block.persistance = persistance
	if block.should_use_uuid:
		persistance.uuid = UUID.v4()
		block.uuid = persistance.uuid
	map_chunk_blocks[grid_pos_string] = persistance
	chunk_node.add_child(block)
	_update_blocks_in_chunk(block_scene, blocks_in_chunk)
func _update_blocks_in_chunk(block_scene: PackedScene, blocks_in_chunk: Dictionary) -> void:
	if blocks_in_chunk.has(block_scene.resource_path):
		blocks_in_chunk[block_scene.resource_path] += 1
	else:
		blocks_in_chunk[block_scene.resource_path] = 1

# Chooses a block type based on its weight and the distance from the spawn point.
func choose_block(grid_pos: Vector2, blocks_in_chunk: Dictionary) -> PackedScene:
	var block_distance = grid_pos.distance_to(spawn_point)
	var valid_blocks = []
	var total_weight = 0.0
	
	for block_config in block_types:
		if _is_valid_block_config(block_config, block_distance, blocks_in_chunk):
			valid_blocks.append(block_config)
			total_weight += block_config.weight
				
	if valid_blocks.size() == 0:
		return null
	
	return _pick_block_based_on_weight(valid_blocks, total_weight)

func _is_valid_block_config(block_config: BlockSpawnConfiguration, block_distance: float, blocks_in_chunk: Dictionary) -> bool:
	return block_config.maximum_per_chunk != 0 and block_distance >= block_config.min_distance and block_distance <= block_config.max_distance and (block_config.maximum_per_chunk == -1 or not blocks_in_chunk.has(block_config.scene.resource_path) or blocks_in_chunk[block_config.scene.resource_path] < block_config.maximum_per_chunk)

func _pick_block_based_on_weight(valid_blocks: Array, total_weight: float) -> PackedScene:
	var r = randf() * total_weight
	for block_config in valid_blocks:
		r -= block_config.weight
		if r <= 0:
			return block_config.scene
	return valid_blocks[valid_blocks.size() - 1].scene

# Checks each loading trigger’s position and generates the corresponding chunk if needed.
func update_chunks() -> void:
	var touched_chunks : Dictionary[String, Variant] = {}
	for trigger in loading_triggers:
		var base_chunk_coord = WorldContext.calculate_base_chunk_coordinate(trigger.global_position)
		if not trigger.is_visible_in_tree(): continue
		_generate_surrounding_chunks(base_chunk_coord, touched_chunks)
	for generated_chunk_key in generated_chunks.keys():
		if not touched_chunks.has(generated_chunk_key):
			var chunk_node : Node2D = generated_chunks[generated_chunk_key]
			generated_chunks.erase(generated_chunk_key)
			chunk_node.queue_free()

func _generate_surrounding_chunks(base_chunk_coord: Vector2i, touched_chunks: Dictionary[String, Variant]):
	var start_time = Time.get_ticks_msec()
	var has_generated_chunks := false
	for offset_x in range(-1, 2):
		for offset_y in range(-1, 2):
			var chunk = base_chunk_coord + Vector2i(offset_x, offset_y)
			var chunk_coord_string = str(chunk)
			touched_chunks[chunk_coord_string] = null
			if generated_chunks.has(chunk_coord_string):
				continue
			generate_chunk(chunk)
			has_generated_chunks = true
	if has_generated_chunks:
		queue_redraw()
		print("Generating chunks took " + str(Time.get_ticks_msec() - start_time))


func _draw() -> void:
	if not chunk_debug_mode: return
	for chunk_node_position in chunk_node_positions:
		var chunk_size_px = Vector2(chunk_size) * Vector2(block_size + block_padding)
		draw_rect(Rect2(chunk_node_position, chunk_size_px), Color.RED, false, 5)
