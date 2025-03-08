extends CharacterBase
class_name Player

@onready var interact_radius := $InteractRadius
var player_index := 0

func _ready() -> void:
	super()
	controller.interacted.connect(_on_input_controller_interact_pressed)
	controller.inventory_opened.connect(_on_input_controller_inventory_opened)
	persistance.copy_state_to_character(self)

func _on_input_controller_interact_pressed() -> void:
	if PlayersContext.players_interact_focus[player_index] == null:
		return
	PlayersContext.players_interact_focus[player_index]._handle_interact()

func _on_input_controller_inventory_opened() -> void:
	inventory.open_view(func(_inventory: PlayerInventory):
		_inventory.equipment_storage = equipment
		_inventory.player = self
	)


func _on_inventory_items_changed() -> void:
	held_item.item = inventory.items[controller.current_item_index]
	_on_current_item_changed(controller.current_item_index)
	
func _on_interact_radius_area_entered(area: Area2D) -> void:
	if area is InteractArea:
		PlayersContext.players_interact_focus[player_index] = area
		PlayersContext.players_interact_focus_changed.emit()

func _on_interact_radius_area_exited(area: Area2D) -> void:
	if area is InteractArea and area == PlayersContext.players_interact_focus[player_index]:
		PlayersContext.players_interact_focus[player_index] = null
		PlayersContext.players_interact_focus_changed.emit()
