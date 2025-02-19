extends Button
class_name ItemSlot

@onready var texture_rect := $MarginContainer/TextureRect
@export var show_stack_size := true
@export var stack_size := 0 : 
	set(value):
		stack_size = value
		handle_stack_size_change(stack_size)
@export var item : Item = null :
	set(value):
		item = value
		handle_item_change(item)
					
func handle_item_change(new_item: Item):
	if item == null:
			texture_rect.texture = null
			disabled = true
	else:
		texture_rect.texture = item.texture
		disabled = false

func _ready() -> void:
	handle_item_change(item)
	handle_stack_size_change(stack_size)

func handle_stack_size_change(size: int):
	%StackCountContainer.visible = size > 1 or (item != null and item.max_stacks > 1)
	%StackSize.text = str(size)
		

func _on_focus_entered() -> void:
	if item:
		TooltipOverlay.describe(self, item.key)
