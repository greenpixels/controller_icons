extends Node
class_name Controller

var movement_input := Vector2(0., 0.)
var look_at_input := Vector2.ZERO
var current_item_index = 0 :
	set(value):
		var previous_item_index = current_item_index
		if value < 0: value = 2
		var new_offset = value % 3
		if new_offset != current_item_index:
			current_item_index = new_offset
			current_item_index_changed.emit(current_item_index, previous_item_index)
		
signal look_at_changed(look_at: Vector2)
signal attacked
signal current_item_index_changed(position: int, previos: int)
