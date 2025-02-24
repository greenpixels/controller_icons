extends PanelContainer
class_name StorageView

@onready var item_slot_scene := preload("res://ui/item_slot/item_slot.tscn")
@onready var grid := %Grid
@export var storage : Storage :
	set(value):
		storage = value
		if storage != null:
			render_items()

signal back_button_pressed
	
func render_items():
	if not storage: return
	for node in grid.get_children():
		node.queue_free()
	var index = 0
	for item in storage.items:
		var slot : ItemSlot = item_slot_scene.instantiate()
		
		slot.storage = storage
		slot.index_in_storage = index
		grid.add_child(slot)
		index += 1
		slot.handle_storage_update()


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
