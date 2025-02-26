extends Button
class_name ItemSlot

@onready var texture_rect := $MarginContainer/TextureRect
@export var show_stack_size := true
var storage : Storage
var index_in_storage : int
var is_drag_source := false :
	set(value):
		is_drag_source = value
		texture_rect.modulate.a = 0.33 if is_drag_source else 1.


func _ready() -> void:
	setup()

func setup():
	handle_storage_update()
	if storage:
		storage.items_changed.connect(handle_storage_update)

		

func handle_storage_update():
	var item = get_item()
	var stack_size = get_stack_size()
	if item == null:
		texture_rect.texture = null
	else:
		texture_rect.texture = item.texture
	%StackCountContainer.visible = stack_size > 1 or (item != null and item.max_stacks > 1)
	%StackSize.text = str(stack_size)

func get_item() -> Item:
	if not storage or index_in_storage >= storage.items.size(): return null
	return storage.items[index_in_storage]

func get_stack_size() -> int:
	if not storage or index_in_storage >= storage.quantities.size(): return 0
	return storage.quantities[index_in_storage]

func _on_focus_entered() -> void:
	if get_item():
		TooltipOverlay.describe(self, get_item().key)
