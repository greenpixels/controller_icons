extends Node
class_name Storage

@export var storage_view : PackedScene
@export var maximum_space := 10
var stacks : Array [int] = []
var items : Array [Item] = []
var is_view_open := false

signal items_changed

func open_view():
	if not storage_view or is_view_open: return
	var view = storage_view.instantiate()
	is_view_open = true
	view.tree_exited.connect(func(): is_view_open = false)
	view.storage = self
	UiLayer.add_child(view)

func _ready() -> void:
	for space in range(maximum_space):
		stacks.push_back(0)
		items.push_back(null)

func _to_string() -> String:
	var output := ""
	var index = 0
	for item in items:
		output += "[{position}]: ".format({"position": index})
		if item != null:
			output += "[ {key} ({amount})]\n".format({"key": item.key, "amount": stacks[index]})
		else:
			output += "[ empty ]\n"
		index += 1
	return output
	
func store_item(item: Item, amount: int) -> int:
	var remaining = amount
	
	# First, try to fill up any existing stacks of the same item.
	for i in range(items.size()):
		if items[i] != null and items[i].key == item.key:
			# If this stack isn’t full, fill it up as much as possible.
			if stacks[i] < item.max_stacks:
				var free_space = item.max_stacks - stacks[i]
				var to_add = min(free_space, remaining)
				stacks[i] += to_add
				remaining -= to_add
				# If we have stored all items, we’re done.
				if remaining == 0:
					return 0
	
	# Next, if there are remaining items, try to add them to empty slots.
	while remaining > 0:
		var found_slot = false
		# Loop over each possible slot index from 0 to maximum_space - 1.
		for i in range(maximum_space):
			if i < items.size():
				# Slot exists; check if it's empty.
				if items[i] == null:
					var to_add = min(remaining, item.max_stacks)
					items[i] = item
					stacks[i] = to_add
					remaining -= to_add
					found_slot = true
					break
			else:
				# Slot does not exist; create a new one.
				var to_add = min(remaining, item.max_stacks)
				items.append(item)
				stacks.append(to_add)
				remaining -= to_add
				found_slot = true
				break
		# If no empty slot was found, break out of the loop.
		if not found_slot:
			break
	
	# Return any items that could not be stored.
	items_changed.emit()
	return remaining


func remove_item(item: Item, amount: int):
	items_changed.emit()

func move_item(item: Item, amount: int):
	items_changed.emit()
	
func sort():
	# Sort the array by name
	items_changed.emit()
	
func serialize_to_json() -> String:
	# Should create an array of objects containing the item-key and the stack amount
	return ""
