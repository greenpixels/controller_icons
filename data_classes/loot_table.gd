extends WeightedList
class_name LootTable

@export var table : Array[LootTableEntry]

# We need to call this function before we can use the LootTable because
# Resource do not have _init or _ready. That sucks ...
func create_entries():
	entries = table
	current_total_weight = 0
	for entry in entries:
		current_total_weight += entry.weight
