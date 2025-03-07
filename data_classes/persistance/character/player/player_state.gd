extends PersistanceCharacterState
class_name PersistancePlayerState

const PLAYER_SAVE_BASE_PATH := "user://players/"
@export_storage var name : String = "No Name"

func save_to_disk():
	if not uuid or uuid.is_empty():
		push_error("Unable to save player state as the UUID is not set")
		return
	var path := PLAYER_SAVE_BASE_PATH + uuid + GameSettings.RESOURCE_SAVE_FILE_EXTENSTION
	var status = ResourceSaver.save(self, path, ResourceSaver.FLAG_COMPRESS)
	if status != OK:
		push_error("Failed to save player")
		print(status)
