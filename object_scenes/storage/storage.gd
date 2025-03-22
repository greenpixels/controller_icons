extends Node
class_name Storage

@export var storage_view: PackedScene
@export var maximum_space: int = 10

# Array of item counts by slot
var quantities: Array[int] = []

# Array of Item references (or null) by slot
var items: Array[Item] = []

# Tracks if the storage view is open
var is_view_open: bool = false

# Callables to run before moving an item into a slot
var before_move_checks: Array[Callable] = []

@warning_ignore("unused_signal")
signal items_changed


func for_each_slot(callback : Callable) -> void: 
	var index = 0
	for item in items:
		var quantity = quantities[index]
		callback.call(item, quantity)
		index += 1
	
## -----------------------------
## UI / View
## -----------------------------
func open_view(view_callback = func(_view: Node): pass) -> void:
	if not storage_view or is_view_open:
		return
	var view = storage_view.instantiate()
	is_view_open = true
	
	# When the view is closed, reset is_view_open
	view.tree_exited.connect(func():
		is_view_open = false
	)
	
	view.storage = self
	view_callback.call(view)
	UiLayer.add_child(view)


## -----------------------------
## Lifecycle
## -----------------------------
func _ready() -> void:
	for i in range(maximum_space):
		quantities.push_back(0)
		items.push_back(null)


## -----------------------------
## Debug/Helpers
## -----------------------------
func _to_string() -> String:
	var output := ""
	for i in range(items.size()):
		output += "[%d]: " % i
		if items[i] != null:
			output += "[ %s (%d) ]\n" % [items[i].key, quantities[i]]
		else:
			output += "[ empty ]\n"
	return output


## -----------------------------
## Internal: Run Before-Move Checks
## -----------------------------
func _run_before_move_checks(item: Item, storage: Storage, slot_index: int) -> bool:
	# Return false as soon as one Callable indicates a failure
	for check in before_move_checks:
		if not check.call(item, storage, slot_index):
			return false
	return true


## -----------------------------
## Slot Operations
## -----------------------------
func _swap_slots(source_slot: int, target_storage: Storage, target_slot: int) -> void:
	var temp_item = items[source_slot]
	var temp_amount = quantities[source_slot]
	
	items[source_slot] = target_storage.items[target_slot]
	quantities[source_slot] = target_storage.quantities[target_slot]
	
	target_storage.items[target_slot] = temp_item
	target_storage.quantities[target_slot] = temp_amount
	
	emit_signal("items_changed")
	target_storage.emit_signal("items_changed")


func transfer_item(source_slot: int, target_storage: Storage):
	if not target_storage:
		return
		
	var slot_index := 0
	for slot in target_storage.items:
		if slot == null or slot == items[source_slot]:
			transfer_item_to(source_slot, target_storage, slot_index)
			return
		slot_index += 1

func transfer_item_to(source_slot: int, target_storage: Storage, target_slot: int) -> void:
	if not target_storage or (self == target_storage and source_slot == target_slot):
		return

	

	var source_item = items[source_slot]
	var source_amount = quantities[source_slot]
	var target_item = target_storage.items[target_slot]
	var target_amount = target_storage.quantities[target_slot]
	if not target_storage._run_before_move_checks(source_item, target_storage, target_slot): return
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

			# Otherwise, try merging items into target slot.
			var remaining = target_storage.store_item_at(source_item, source_amount, target_slot)
			if remaining == 0:
				# Everything stored, remove from source slot
				items[source_slot] = null
				quantities[source_slot] = 0
			else:
				# Some leftover that wasn't stored
				quantities[source_slot] = remaining

			emit_signal("items_changed")
			target_storage.emit_signal("items_changed")
			return
		else:
			# Different item types, just swap
			_swap_slots(source_slot, target_storage, target_slot)
			return

	# When one slot is empty, just swap
	_swap_slots(source_slot, target_storage, target_slot)


## -----------------------------
## Store / Remove Items
## -----------------------------
func store_item_at(item: Item, amount: int, index: int) -> int:
	if index >= maximum_space:
		return amount  # Invalid index; nothing stored

	# --- Before-Move Checks ---
	# If any check fails, we do NOT store anything and return the original amount.
	if not _run_before_move_checks(item, self, index):
		return amount

	var remaining = amount
	# If the slot is empty
	if items[index] == null:
		items[index] = item
		var to_add = min(remaining, item.max_stacks)
		quantities[index] = to_add
		remaining -= to_add
	# If the slot is the same item type
	elif items[index].key == item.key:
		var free_space = items[index].max_stacks - quantities[index]
		if free_space > 0:
			var to_add = min(remaining, free_space)
			quantities[index] += to_add
			remaining -= to_add
	else:
		# Slot is a different item type; cannot store
		return remaining

	emit_signal("items_changed")
	return remaining

func store_item(item: Item, amount: int) -> int:
	var remaining = amount

	# First try to merge with existing stacks of the same type
	for i in range(maximum_space):
		if remaining <= 0:
			break
		if items[i] != null and items[i].key == item.key and quantities[i] < item.max_stacks:
			remaining = store_item_at(item, remaining, i)
			if remaining == 0:
				break

	# Then fill empty slots
	for i in range(maximum_space):
		if remaining <= 0:
			break
		if items[i] == null:
			remaining = store_item_at(item, remaining, i)
			if remaining == 0:
				break

	return remaining

func drop_all(spawn_position: Vector2, exact = false):
	var index = 0
	for item in items:
		if item != null:
			var offset = Vector2(randf() * (WorldContext.BLOCK_SIZE.x / 2.), randf() * (WorldContext.BLOCK_SIZE.y / 2.)) if not exact else Vector2.ZERO
			ItemContext.spawn_item_at(item, spawn_position + offset, quantities[index])
		index += 1

func remove_item(_item: Item, _amount: int) -> void:
	var to_remove = _amount

	# Go through all slots and remove from those matching _item.key
	for i in range(maximum_space):
		if items[i] != null and items[i].key == _item.key:
			var can_remove = min(to_remove, quantities[i])
			quantities[i] -= can_remove
			to_remove -= can_remove

			# If this stack is now empty, clear the slot
			if quantities[i] <= 0:
				items[i] = null
				quantities[i] = 0

			# Stop if we've removed everything we need
			if to_remove <= 0:
				break

	# Emit signal to notify anything listening that our storage changed
	emit_signal("items_changed")


## -----------------------------
## Sort / Serialize
## -----------------------------
func sort_items() -> void:
	# Sorting logic here
	emit_signal("items_changed")


func serialize_to_json() -> String:
	# Serialization logic here
	return ""

func to_dict():
	var dict = {}
	var item_index = 0
	for item in items:
		if item == null:
			item_index += 1
			continue
		if dict.has(item.key):
			dict[item.key] += quantities[item_index]
		else:
			dict[item.key] = quantities[item_index]
		item_index += 1
	return dict
