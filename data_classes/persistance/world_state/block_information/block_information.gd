extends Resource
class_name PersistanceBlockInformation

@export_storage var block_key : String
# Only blocks with extra information need to be peristed (Dungeons, Cave, etc ...)
# Other will have an empty UUID
@export_storage var uuid : String = ""
@export_storage var position_in_chunk_grid : Vector2i
@export_storage var chunk_key : String

func init(_block_key: String, _position_in_chunk_grid: Vector2i, _chunk_coord_string: String) -> void:
	block_key = _block_key
	position_in_chunk_grid = _position_in_chunk_grid
	chunk_key = _chunk_coord_string
	
	
