extends Resource
class_name PersistanceChunkInformation

@export_storage var chunk_key : String
@export_storage var blocks : Dictionary[String, PersistanceBlockInformation] = {}
@export_storage var item_pickups : Dictionary[String, PersistanceItemPickupState] = {}
@export_storage var npcs : Dictionary[String, PersistanceNpcState] = {}

func init(_key: String):
	chunk_key = _key
