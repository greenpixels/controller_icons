extends Resource
class_name PersistanceCharacterState

@export_storage var uuid : String = UUID.v4()
@export_storage var inventory_quantities: Array[int] = []
@export_storage var equipment_quantities: Array[int] = []
@export_storage var inventory : Array[Variant] = []
@export_storage var equipment : Array[Variant] = []
@export_storage var human_style : PersistanceHumanStyle = PersistanceHumanStyle.new()
@export_storage var current_health : int = 100
@export_storage var maximum_health : int = 100

func copy_character_to_state(character: CharacterBase):
	inventory = []
	for item in character.inventory.items:
		if item == null: inventory.push_back(null)
		else: inventory.push_back(item.key)
	equipment = []
	for item in character.equipment.items:
		if item == null: equipment.push_back(null)
		else: equipment.push_back(item.key)
	inventory_quantities = character.inventory.quantities
	equipment_quantities = character.equipment.quantities

func copy_state_to_character(character: CharacterBase):
	character.inventory.items = ItemContext.convert_item_keys_to_items(inventory)
	while character.inventory.items.size() < character.inventory.maximum_space:
		character.inventory.items.push_back(null)
		
	character.inventory.quantities = inventory_quantities
	while character.inventory.quantities.size() < character.inventory.maximum_space:
		character.inventory.quantities.push_back(0)
		
	character.equipment.items = ItemContext.convert_item_keys_to_items(equipment)
	while character.equipment.items.size() < character.equipment.maximum_space:
		character.equipment.items.push_back(null)
		
	character.equipment.quantities = equipment_quantities
	while character.equipment.quantities.size() < character.equipment.maximum_space:
		character.equipment.quantities.push_back(0)
	
	character.inventory.items_changed.emit()
	character.equipment.items_changed.emit()

func add_item(item_key: String, amount: int):
	if not ItemContext.item_path_lookup.has(item_key):
		push_error("Item key '%s' not found in lookup" % item_key)
		return
	inventory.push_back(item_key)
	inventory_quantities.push_back(amount)
	
func equip_item(item_key: String, slot: PlayerInventory.ArmorSlotPositions):
	if not ItemContext.item_path_lookup.has(item_key):
		push_error("Item key '%s' not found in lookup" % item_key)
		return
	for index in PlayerInventory.ArmorSlotPositions.size():
		if index >= equipment.size():
			equipment.push_back(null)
		if index >= equipment_quantities.size():
			equipment_quantities.push_back(0)
		if index == slot:
			equipment[slot] = item_key
			equipment_quantities[slot] = 1
			
