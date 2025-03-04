extends CanvasLayer
@onready var dragged_item_texture := %DraggedItemTexture
var drag_source: ItemSlot = null
var drop_target: ItemSlot = null
var item: Item = null

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	FocusContext.focus_changed.connect(func(node: Control):
		if not node is ItemSlot:
			_cancel_drag()
	)

func _on_node_added(node: Node) -> void:
	if not node is Control:
		return
	if node.focus_mode != Control.FOCUS_NONE:
		if node is ItemSlot:
			node.focus_entered.connect(func():
				_on_slot_focused(node)
			)
			node.button_down.connect(func():
				_drag(node)
			)
			node.button_up.connect(func():
				_drop()
			)
			node.mouse_exited.connect(node.release_focus)

func _on_node_removed(node: Node) -> void:
	if node is ItemSlot and (node == drag_source or node == drop_target):
		_cancel_drag()

func _on_slot_focused(node: ItemSlot) -> void:
	drop_target = node
	if item:
		TweenHelper.tween("drag_animation", self) \
			.tween_property(dragged_item_texture, "global_position", node.global_position, 0.3) \
			.set_trans(Tween.TRANS_SPRING) \
			.set_ease(Tween.EASE_OUT)

func _drag(slot: ItemSlot) -> void:
	if drag_source or slot.get_item() == null:
		_cancel_drag()
		return
	drag_source = slot
	drag_source.is_drag_source = true
	item = slot.get_item()
	dragged_item_texture.show()
	dragged_item_texture.texture = item.texture
	dragged_item_texture.global_position = slot.global_position

func _drop() -> void:
	if not drag_source or not drop_target:
		_cancel_drag()
		return
	drag_source.storage.transfer_item_to(drag_source.index_in_storage, drop_target.storage, drop_target.index_in_storage)
	_cancel_drag()

func _cancel_drag() -> void:
	if drag_source and is_instance_valid(drag_source):
		drag_source.is_drag_source = false
	item = null
	drag_source = null
	drop_target = null
	dragged_item_texture.hide()
