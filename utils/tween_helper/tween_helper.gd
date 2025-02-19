## A helper class for managing tweens efficiently.
##
## This class stores tweens in a dictionary and ensures old or inactive tweens 
## are cleaned up periodically. It prevents multiple tweens from overlapping 
## on the same property of an object.
extends Node

## A dictionary that stores active tweens, using a unique key per tween.
var tweens_dict: Dictionary = {}

## Called when the node is added to the scene.
##
## Starts a timer that periodically triggers the `cleanup` function
## to remove inactive tweens.
func _ready():
	get_tree().create_timer(1).timeout.connect(cleanup)

## Removes inactive tweens from the dictionary.
##
## This function iterates over the stored tweens and removes any that are 
## no longer running to free up memory and prevent redundant animations.
func cleanup():
	for key in tweens_dict.keys():
		if tweens_dict.has(key) and not (tweens_dict[key] as Tween).is_running():
			(tweens_dict[key] as Tween).kill()
			tweens_dict.erase(key)

## Creates or retrieves a tween associated with a given reference name and node.
##
## Ensures that if a tween already exists for the same reference name on a node,
## it is stopped before a new one is created. This prevents conflicts between tweens.
##
## @param reference_name A unique name identifying the tween.
## @param origin_node The node to which the tween is applied.
## @returns The newly created or retrieved tween.
func tween(reference_name: String, origin_node: Node) -> Tween:
	var key = str(origin_node.get_instance_id()) + "_" + reference_name
	if tweens_dict.has(key) and (tweens_dict[key] as Tween).is_running():
		(tweens_dict[key] as Tween).kill()
	tweens_dict[key] = origin_node.create_tween()
	return tweens_dict[key]
