extends PanelContainer
class_name StorageView

@onready var item_slot_scene := preload("res://ui/item_slot/item_slot.tscn")
@onready var grid := %Grid
@export var storage : Storage :
	set(value):
		if storage:
				storage.items_changed.disconnect(render_items)
		storage = value
		if storage != null:
			render_items()
			storage.items_changed.connect(render_items)

signal back_button_pressed
	
func render_items():
	if not storage: return
	for node in grid.get_children():
		node.queue_free()
	var index = 0
	for item in storage.items:
		var slot : ItemSlot = item_slot_scene.instantiate()
		grid.add_child(slot)
		slot.item = item
		slot.stack_size = storage.stacks[index]
		index += 1


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
