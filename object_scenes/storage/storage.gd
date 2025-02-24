extends Node
class_name Storage

@export var storage_view: PackedScene
@export var maximum_space: int = 10
var quantities: Array[int] = []
var items: Array[Item] = []
var is_view_open: bool = false

@warning_ignore("unused_signal")
signal items_changed

## Opens the storage view if it is not already open.
##
## @returns void.
func open_view() -> void:
	if not storage_view or is_view_open:
		return
	var view = storage_view.instantiate()
	is_view_open = true
	view.tree_exited.connect(func():
		is_view_open = false
	)
	view.storage = self
	UiLayer.add_child(view)

## Initializes storage slots based on maximum_space.
##
## @returns void.
func _ready() -> void:
	for i in range(maximum_space):
		quantities.push_back(0)
		items.push_back(null)

## Returns a string representation of storage slots.
##
## @returns A string representation of storage slots.
func _to_string() -> String:
	var output := ""
	for i in range(items.size()):
		output += "[%d]: " % i
		if items[i] != null:
			output += "[ %s (%d) ]\n" % [items[i].key, quantities[i]]
		else:
			output += "[ empty ]\n"
	return output

## Swaps the item and quantity between a slot in this storage and a slot in another storage.
##
## @param source_slot The slot index in this storage.
## @param target_storage The storage instance to swap with.
## @param target_slot The slot index in the target storage.
## @returns void.
func _swap_slots(source_slot: int, target_storage: Storage, target_slot: int) -> void:
	var temp_item = items[source_slot]
	var temp_amount = quantities[source_slot]
	items[source_slot] = target_storage.items[target_slot]
	quantities[source_slot] = target_storage.quantities[target_slot]
	target_storage.items[target_slot] = temp_item
	target_storage.quantities[target_slot] = temp_amount
	emit_signal("items_changed")
	target_storage.emit_signal("items_changed")

## Transfers an item from a slot in this storage to a slot in the target storage.
##
## @param source_slot The source slot index in this storage.
## @param target_storage The target storage instance.
## @param target_slot The target slot index in the target storage.
## @returns void.
func transfer_item(source_slot: int, target_storage: Storage, target_slot: int) -> void:
	if not target_storage or (self == target_storage and source_slot == target_slot):
		return

	var source_item = items[source_slot]
	var source_amount = quantities[source_slot]
	var target_item = target_storage.items[target_slot]
	var target_amount = target_storage.quantities[target_slot]

	# If both slots are empty, nothing to transfer.
	if source_item == null and target_item == null:
		return

	# When both slots are occupied.
	if source_item != null and target_item != null:
		if source_item.key == target_item.key:
			# If target slot is full, swap items.
			if target_amount == target_item.max_stacks:
				_swap_slots(source_slot, target_storage, target_slot)
				return
			# Otherwise, merge items into target slot.
			var remaining = target_storage.store_item_at(source_item, source_amount, target_slot)
			if remaining == 0:
				items[source_slot] = null
				quantities[source_slot] = 0
			else:
				quantities[source_slot] = remaining
			emit_signal("items_changed")
			target_storage.emit_signal("items_changed")
			return
		else:
			_swap_slots(source_slot, target_storage, target_slot)
			return

	# When one slot is empty, swap them.
	_swap_slots(source_slot, target_storage, target_slot)

## Stores a given amount of an item at a specific slot index.
##
## @param item The item to store.
## @param amount The amount of the item to store.
## @param index The slot index where the item should be stored.
## @returns The remaining amount that could not be stored.
func store_item_at(item: Item, amount: int, index: int) -> int:
	if index >= maximum_space:
		return amount

	var remaining = amount
	if items[index] == null:
		items[index] = item
		var to_add = min(remaining, item.max_stacks)
		quantities[index] = to_add
		remaining -= to_add
	elif items[index].key == item.key:
		var free_space = item.max_stacks - quantities[index]
		if free_space > 0:
			var to_add = min(remaining, free_space)
			quantities[index] += to_add
			remaining -= to_add
	else:
		return remaining

	emit_signal("items_changed")
	return remaining

## Attempts to store a given amount of an item in available slots.
##
## @param item The item to store.
## @param amount The amount of the item to store.
## @returns The remaining amount that could not be stored.
func store_item(item: Item, amount: int) -> int:
	var remaining = amount
	# Fill existing stacks.
	for i in range(maximum_space):
		if items[i] != null and items[i].key == item.key and quantities[i] < item.max_stacks:
			var free_space = item.max_stacks - quantities[i]
			var to_add = min(free_space, remaining)
			quantities[i] += to_add
			remaining -= to_add
			if remaining == 0:
				emit_signal("items_changed")
				return 0

	# Fill empty slots.
	for i in range(maximum_space):
		if remaining <= 0:
			break
		if items[i] == null:
			items[i] = item
			var to_add = min(remaining, item.max_stacks)
			quantities[i] = to_add
			remaining -= to_add
	emit_signal("items_changed")
	return remaining

## Removes a specified amount of an item from storage.
##
## @param item The item to remove.
## @param amount The amount to remove.
## @returns void.
func remove_item(_item: Item, _amount: int) -> void:
	emit_signal("items_changed")
	
## Sorts storage items by name.
##
## @returns void.
func sort_items() -> void:
	emit_signal("items_changed")
	
## Serializes storage contents to JSON.
##
## @returns A JSON string representing the storage contents.
func serialize_to_json() -> String:
	return ""
