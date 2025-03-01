extends Resource
class_name PersistanceBlockInformation

@export_storage var block_key : String
# Only blocks with extra information need to be peristed (Dungeons, Cave, etc ...)
@export_storage var uuid : String = ""
@export_storage var chunk_position : Vector2

func _init(_block_key: String, _chunk_position: Vector2) -> void:
	block_key = _block_key
	chunk_position = _chunk_position
	
	
