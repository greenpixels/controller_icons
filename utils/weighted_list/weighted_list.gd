## A weighted list data structure for storing objects with associated weights.
## 
## This class allows for storing objects with specific weights, enabling
## weighted random selection. The higher the weight, the higher the probability
## of selection when calling `pick_weighted_random()`.

extends Resource
class_name WeightedList


var entries: Array[Variant] = [] ## Array[{object: Variant, weight: int}]
var current_total_weight: int = 0

## Adds an item to the weighted list with a given weight.
##
## @param item The object to be added.
## @param weight The weight assigned to the object.
## @returns void
func push_entry(item: Variant, weight: int) -> void:
	entries.append({"object": item, "weight": weight})
	current_total_weight += weight

## Removes an item from the weighted list.
##
## @param item The object to be removed.
## @returns `true` if the item was found and removed, otherwise `false`.
func remove_entry(item: Variant) -> bool:
	for i in range(entries.size()):
		if entries[i]["object"] == item:
			current_total_weight -= entries[i]["weight"]
			entries.remove_at(i)
			return true
	return false

## Picks a random item from the list based on weight.
##
## The higher the weight of an item, the greater the probability of selection.
## If the list is empty, an empty dictionary is returned.
##
## @returns A dictionary containing the selected item and its weight, or an empty dictionary if the list is empty.
func pick_weighted_random() -> Variant:
	if current_total_weight <= 0:
		return null
	var threshold: int = randi_range(0, current_total_weight - 1)
	entries.shuffle()
	for entry in entries:
		threshold -= entry["weight"]
		if threshold < 0:
			return entry
	return null
