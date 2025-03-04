extends Resource
class_name PersistanceItemPickupState

@export_storage var uuid : String = UUID.v4()
@export_storage var position := Vector2.ZERO
@export_storage var item_key : String
@export_storage var chunk_key : String
@export_storage var amount : int
@export_storage var remaining_time_sec := 5. * 60.
