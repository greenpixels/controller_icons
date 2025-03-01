extends Resource
class_name PersistanceMapState

@export_storage var uuid : String
# "CHUNK_KEY" (COORDS) : PersistanceChunkInformation
@export_storage var chunks : Dictionary
@export_storage var location_key : String
@export_storage var last_player_position : Vector2 = Vector2.ZERO

func _init(_uuid: String, _location : Location) -> void:
	uuid = _uuid
	chunks = {}
	location_key = _location.key
