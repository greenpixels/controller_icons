extends Resource
class_name PersistanceWorldState
@export_storage var main_seed : int
@export_storage var current_sub_seed : int
@export_storage var current_map_uuid_stack : Array[String]
@export_storage var uuid : String
# "UUID" : PersistanceMapState
@export_storage var maps : Dictionary 

func _init() -> void:
	randomize()
	uuid = UUID.v4()
	main_seed = randi()
	current_map_uuid_stack.push_back("main")

func set_map(map : PersistanceMapState):
	maps[map.uuid] = map

func get_map(_uuid: String) -> PersistanceMapState:
	if maps.has(_uuid):
		return maps[_uuid]
	return null

func save():
	ResourceSaver.save(self, "user://worlds/" + uuid + ".tres")
