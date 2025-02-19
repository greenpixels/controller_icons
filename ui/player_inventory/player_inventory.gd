extends Panel
class_name PlayerInventory

@export var storage : Storage
@onready var inventory := $Inventory

func _ready() -> void:
	if storage:
		inventory.storage = storage
		inventory.render_items()


func _on_inventory_back_button_pressed() -> void:
	queue_free()
