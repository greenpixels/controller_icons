extends Node
class_name WorldGenerator

# The default block. For now, we use the default block for world building.
var dirt_block := preload("res://object_scenes/blocks/_all/dirt/block_dirt.tscn")

# The spawn point (expressed in grid coordinates)
@export var spawn_point := Vector2(0, 0)
# Extra padding (in pixels) between blocks.
@export var block_padding := Vector2(6, 6)
# The pixel size of any block in the grid
@export var block_size := Vector2(192, 156)
# The padding around the spawn point (in grid units) in which – including the spawn point itself – no blocks are spawned
@export var spawn_point_empty_padding := Vector2(2, 2)
# The amount of blocks in a chunk (width, height in grid units)
@export var chunk_size := Vector2(10, 10)

# FastNoiseLite parameters for creating empty areas.
var noise: FastNoiseLite;
@export var empty_area_threshold: float = -0.2  # Blocks are only placed if noise >= this value.
@export var noise_frequency: float = 0.1
@export var noise_seed: int = 12345

# A loading trigger is a node with a position.
# We check whether the position of any loading trigger should trigger a chunk update.
@export var loading_triggers: Array[Node2D] = []

# (Optional) Array of block types.
# Each element should be an instance of WorldGenBlockConfig (or BlockSpawnConfiguration).
# If this array is empty, the default dirt_block is always used.
@export var block_types: Array[BlockSpawnConfiguration] = []

# Holds already generated chunks (keyed by their chunk coordinate)
var generated_chunks := {}

func _ready() -> void:
	seed(noise_seed)
	noise = FastNoiseLite.new()
	
	# Initialize the noise generator.
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
	noise.frequency = noise_frequency

	# Connect players to trigger chunk updates.
	for player in PlayersContext.players:
		if not loading_triggers.has(player):
			player.moved.connect(func(_position):
				update_chunks()
			)
			loading_triggers.push_back(player)
	update_chunks()
	PlayersContext.players_changed.connect(
		func():
			for player in PlayersContext.players:
				if not loading_triggers.has(player):
					player.moved.connect(func(_position):
						update_chunks()
					)
					loading_triggers.push_back(player)
			update_chunks()
	)
	
# Generates a chunk at the given chunk coordinate (each chunk is chunk_size blocks in width and height)
func generate_chunk(chunk_coord: Vector2) -> void:
	# Do not generate if already created.
	if generated_chunks.has(chunk_coord):
		return
	var sum_ab = chunk_coord.x + chunk_coord.y
	seed(noise_seed + ((sum_ab * (sum_ab + 1)) / 2) + chunk_coord.y)
	var chunk_node = Node2D.new()
	chunk_node.name = "Chunk_%d_%d" % [chunk_coord.x, chunk_coord.y]
	chunk_node.y_sort_enabled = true
	get_parent().add_child.call_deferred(chunk_node)
	
	# Loop through every block position within the chunk.
	for x in range(int(chunk_size.x)):
		for y in range(int(chunk_size.y)):
			# Compute the grid coordinate for this block.
			var grid_pos = Vector2(chunk_coord.x * chunk_size.x + x, chunk_coord.y * chunk_size.y + y)
			
			# Check if the block falls within the spawn point empty padding.
			# (Assumes spawn_point is in grid coordinates.)
			if abs(grid_pos.x - spawn_point.x) < spawn_point_empty_padding.x and abs(grid_pos.y - spawn_point.y) < spawn_point_empty_padding.y:
				continue  # Skip placing a block in the empty zone.
			
			# Use FastNoise to create empty areas.
			var noise_value = noise.get_noise_2d(grid_pos.x, grid_pos.y)
			if noise_value < empty_area_threshold:
				continue  # Skip this block position to create an empty area.
			
			# Choose which block to spawn.
			# If block_types is not empty, pick based on weight and distance; otherwise, use the default dirt_block.
			var block_scene: PackedScene = dirt_block
			if block_types.size() > 0:
				var chosen_scene = choose_block(grid_pos)
				if chosen_scene:
					block_scene = chosen_scene
			
			var block_instance = block_scene.instantiate()
			# Calculate effective size (block size + padding) for positioning.
			var effective_size = block_size + block_padding
			block_instance.position = grid_pos * effective_size
			chunk_node.add_child(block_instance)
	
	# Mark this chunk as generated.
	generated_chunks[chunk_coord] = chunk_node

# Chooses a block type based on its weight and the distance from the spawn point.
func choose_block(grid_pos: Vector2) -> PackedScene:
	# Calculate the distance (in blocks) from the spawn point.
	var block_distance = grid_pos.distance_to(spawn_point)
	var valid_blocks = []
	var total_weight = 0.0
	
	# Loop through each block configuration.
	# Each block_config is expected to be an instance of WorldGenBlockConfig (or BlockSpawnConfiguration).
	for block_config in block_types:
		# Check if the current block_distance is within the allowed range.
		if block_distance >= block_config.min_distance and block_distance <= block_config.max_distance:
			valid_blocks.append(block_config)
			total_weight += block_config.weight
	
	# If none meet the distance requirement, return null (which will cause the default to be used).
	if valid_blocks.size() == 0:
		return null
	
	# Pick a random block based on weight.
	var r = randf() * total_weight
	for block_config in valid_blocks:
		r -= block_config.weight
		if r <= 0:
			return block_config.scene
			
	# Fallback: return the scene of the last valid block.
	return valid_blocks[valid_blocks.size() - 1].scene

# Checks each loading trigger’s position and generates the corresponding chunk if needed.
func update_chunks() -> void:
	for trigger in loading_triggers:
		# Convert the trigger's position (in pixels) to grid coordinates.
		var grid_pos = trigger.position / (block_size + block_padding)
		# Determine the base chunk coordinate by dividing by chunk_size.
		var base_chunk_coord = Vector2(
			floor(grid_pos.x / chunk_size.x),
			floor(grid_pos.y / chunk_size.y)
		)
		# Load the base chunk and its eight neighboring chunks.
		for offset_x in range(-1, 2):  # -1, 0, 1
			for offset_y in range(-1, 2):
				var neighbour_chunk = base_chunk_coord + Vector2(offset_x, offset_y)
				generate_chunk(neighbour_chunk)
