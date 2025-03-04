extends Resource
class_name PersistancePlayerState

const PLAYER_SAVE_BASE_PATH := "user://players/"

@export_storage var uuid : String = UUID.v4()
@export_storage var name : String = "No Name"

@export_storage var inventory_quantities: Array[int] = []
@export_storage var equipment_quantities: Array[int] = []
@export_storage var inventory : Array[Variant] = []
@export_storage var equipment : Array[Variant] = []

func copy_player_to_state(player: Player):
	inventory = []
	for item in player.inventory.items:
		if item == null: inventory.push_back(null)
		else: inventory.push_back(item.key)
	equipment = []
	for item in player.equipment.items:
		if item == null: equipment.push_back(null)
		else: equipment.push_back(item.key)
	inventory_quantities = player.inventory.quantities
	equipment_quantities = player.equipment.quantities

func copy_state_to_player(player: Player):
	player.inventory.items = ItemContext.convert_item_keys_to_items(inventory)
	while player.inventory.items.size() < player.inventory.maximum_space:
		player.inventory.items.push_back(null)
		
	player.inventory.quantities = inventory_quantities
	while player.inventory.quantities.size() < player.inventory.maximum_space:
		player.inventory.quantities.push_back(0)
		
	player.equipment.items = ItemContext.convert_item_keys_to_items(equipment)
	while player.equipment.items.size() < player.equipment.maximum_space:
		player.equipment.items.push_back(null)
		
	player.equipment.quantities = equipment_quantities
	while player.equipment.quantities.size() < player.equipment.maximum_space:
		player.equipment.quantities.push_back(0)
	
	player.inventory.items_changed.emit()
	player.equipment.items_changed.emit()

func save_to_disk():
	if not uuid or uuid.is_empty():
		push_error("Unable to save player state as the UUID is not set")
		return
	var path := PLAYER_SAVE_BASE_PATH + uuid + ".tres"
	var status = ResourceSaver.save(self, path)
	if status != OK:
		push_error("Failed to save player")
		print(status)
