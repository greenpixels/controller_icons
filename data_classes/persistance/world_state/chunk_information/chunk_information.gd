extends Resource
class_name PersistanceChunkInformation

@export_storage var chunk_key : String
@export_storage var blocks : Dictionary

func _init(_key: String):
	chunk_key = _key
	blocks = {}
