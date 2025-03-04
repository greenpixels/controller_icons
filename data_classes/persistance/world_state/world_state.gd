extends Resource
class_name PersistanceWorldState

const WORLD_SAVE_BASE_PATH := "user://worlds/"

@export_storage var name := "A new world"
@export_storage var original_seed_text := ""
@export_storage var main_seed : int = 0
@export_storage var current_sub_seed : int = 0
@export_storage var uuid : String = UUID.v4()
# "UUID" : PersistanceMapState
@export_storage var maps : Dictionary 

func set_map(map : PersistanceMapState):
	maps[map.uuid] = map

func get_map(_uuid: String) -> PersistanceMapState:
	if maps.has(_uuid):
		return maps[_uuid] as PersistanceMapState
	return null

func save_to_disk():
	if not uuid or uuid.is_empty():
		push_error("Unable to save player state as the UUID is not set")
		return
	var path := WORLD_SAVE_BASE_PATH + uuid + GameSettings.RESOURCE_SAVE_FILE_EXTENSTION
	var status = ResourceSaver.save(self, path, ResourceSaver.FLAG_COMPRESS)
	if status != OK:
		push_error("Failed to save world")
		print(status)
