extends Resource
class_name PersistanceMapState

@export_storage var uuid : String = UUID.v4()
# "CHUNK_KEY" (COORDS) : PersistanceChunkInformation
@export_storage var chunks : Dictionary = {}
@export_storage var location_key : String = "main"
@export_storage var last_player_position : Vector2 = Vector2.ZERO
# uuid: PersistanceItemPickupState

func init(_uuid: String, _location : Location) -> void:
	uuid = _uuid
	location_key = _location.key

func add_item_pickup(_pickup: ItemPickup):
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(_pickup.position)
	if not _pickup.persistance:
		var persistance := PersistanceItemPickupState.new()
		_pickup.persistance = persistance
		_pickup.persistance.uuid = UUID.v4()
	_pickup.persistance.chunk_key = str(chunk_coord)
	_pickup.persistance.item_key = _pickup.item.key
	_pickup.persistance.position = _pickup.position
	_pickup.persistance.amount = _pickup.amount
	if not chunks.has(_pickup.persistance.chunk_key): return
	var chunk = chunks[_pickup.persistance.chunk_key]
	chunk.item_pickups[_pickup.persistance.uuid] = _pickup.persistance

func remove_item_pickup(_pickup: ItemPickup):
	if not chunks.has(_pickup.persistance.chunk_key): return
	var chunk = chunks[_pickup.persistance.chunk_key]
	if chunk.item_pickups.has(_pickup.persistance.uuid):
		chunk.item_pickups.erase(_pickup.persistance.uuid)
		print(chunk)

func remove_block(block : Block):
	if not chunks.has(block.persistance.chunk_key): return
	var block_key = str(block.persistance.position_in_chunk_grid)
	var chunk = chunks[block.persistance.chunk_key]
	if not chunk.blocks.has(block_key): return
	chunk.blocks.erase(block_key)

func add_block(block : Block):
	pass
