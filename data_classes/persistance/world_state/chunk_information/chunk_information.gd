extends Resource
class_name PersistanceChunkInformation

@export_storage var chunk_key : String
# PersistanceBlockInformation
@export_storage var blocks : Dictionary = {}
@export_storage var item_pickups : Dictionary = {}

func init(_key: String):
	chunk_key = _key
