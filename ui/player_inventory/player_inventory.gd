extends Panel
class_name PlayerInventory

enum ArmorSlotPositions {
	HELMET,
	BODY,
	SHOES,
	RING_1,
	RING_2
}

@export var equipment_storage : Storage
@export var storage : Storage
@export var player : Player
@onready var inventory := $Inventory
@onready var equipment_slots : Array[ItemSlot] =  [%HelmetSlot, %BodySlot, %ShoesSlot, %RightRing, %LeftRing]
@onready var crafting_entry_scene := preload("res://ui/crafting_entry/crafting_entry.tscn")
@onready var crafting_list := %CraftingList
var crafting_entries : Array = []

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("equip"):
		var slot = FocusContext.current_focus
		if slot is ItemSlot:
			if slot.get_item() == null or not slot.get_item() is Equipment: return
			if slot.storage == storage:
				match slot.get_item().slot:
					Equipment.EquipmentSlot.HEAD: slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.HELMET)
					Equipment.EquipmentSlot.BODY: slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.BODY)
					Equipment.EquipmentSlot.SHOES: slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.SHOES)
					Equipment.EquipmentSlot.RING:
						if equipment_storage.items[ArmorSlotPositions.RING_1] == null:
							slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.RING_1)
						elif equipment_storage.items[ArmorSlotPositions.RING_2] == null:
							slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.RING_1)
						else:
							slot.storage.transfer_item_to(slot.index_in_storage, equipment_storage, ArmorSlotPositions.RING_1)
			elif slot.storage == equipment_storage:
				slot.storage.transfer_item(slot.index_in_storage, storage)
	if Input.is_action_just_pressed("drop_item"):
		var slot = FocusContext.current_focus
		if slot is ItemSlot:
			if slot.get_item() == null: return
			
			var pickup : ItemPickup = load("res://object_scenes/item_pickup/item_pickup.tscn").instantiate()
			pickup.item = slot.storage.items[slot.index_in_storage]
			pickup.amount = slot.storage.quantities[slot.index_in_storage]
			slot.storage.items[slot.index_in_storage] = null
			slot.storage.quantities[slot.index_in_storage] = 0
			get_tree().current_scene.add_child.call_deferred(pickup)
			pickup.global_position = player.global_position
			slot.storage.items_changed.emit()
			
				
func _ready() -> void:
	if storage:
		inventory.storage = storage
		inventory.render_items()
	if equipment_storage:
		var index := 0
		
		equipment_storage.before_move_checks.push_back(func(item : Item, storage : Storage, slot: int):
			if item is not Equipment: return false
			match item.slot:
				Equipment.EquipmentSlot.HEAD: if slot != ArmorSlotPositions.HELMET: return false
				Equipment.EquipmentSlot.BODY: if slot != ArmorSlotPositions.BODY: return false
				Equipment.EquipmentSlot.SHOES: if slot != ArmorSlotPositions.SHOES: return false
				Equipment.EquipmentSlot.RING: if slot != ArmorSlotPositions.RING_1 or slot != ArmorSlotPositions.RING_2: return false
				_: return false
			return true
		)
		
		for slot in equipment_slots:
			slot.storage = equipment_storage
			slot.index_in_storage = index
			slot.setup()
			index += 1
	print(ItemContext.craftable_items[0].key)
	for item in ItemContext.craftable_items:
		var entry = crafting_entry_scene.instantiate()
		entry.item = item
		crafting_entries.push_back(entry)
		entry.craft_item_pressed.connect(on_craft_item_pressed)
		crafting_list.add_child(entry)
		print("Added child entry")
	update_crafting_entries()

func update_crafting_entries():
	var item_dict = storage.to_dict() 
	for entry in crafting_entries:
		entry.set_disabled(!entry.item.check_craftable_from_item_dict(item_dict))
		entry.item_dict = item_dict

func on_craft_item_pressed(item : Item):
	if not item.recipe: return
	var item_dict = storage.to_dict()
	if not item.check_craftable_from_item_dict(item_dict): return
	for ingredient in item.recipe.ingredients:
		storage.remove_item(ingredient.item, ingredient.amount)
	storage.store_item(item, 1)
	update_crafting_entries()

func _on_inventory_back_button_pressed() -> void:
	queue_free()
