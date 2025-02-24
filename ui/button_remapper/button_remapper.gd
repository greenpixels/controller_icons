extends Panel
class_name ButtonRemapper

@onready var button_remap_control_scene := preload("res://ui/button_remapper/button_remap_control/button_remap_control.tscn")
@export var input_controller_index := 0
@export var device_index_to_use := 0 : 
	set(value):
		device_index_to_use = value
		# ControllerIcons._last_controller = device_index_to_use
		InputContext.input_controllers[input_controller_index].input_map.overwrite_device(device_index_to_use)
		%ControllerSelection.text = get_controller_name_at(device_index_to_use)
		for child in remap_controls:
			child.device_to_use = device_index_to_use
		var popup : PopupMenu = %ControllerSelection.get_popup()
		for item_index in range(popup.item_count):
			popup.set_item_text(item_index, get_controller_name_at(item_index))
var remap_controls : Array[ActionRemapControl] = [] 


func get_controller_name_at(index: int):
	var controller_name = Input.get_joy_name(index)
	if controller_name.is_empty():
		controller_name = "Not connected"
	return controller_name + " " + str(index + 1)

func _ready() -> void:
	var popup : PopupMenu = %ControllerSelection.get_popup()
	popup.id_pressed.connect(on_controller_selected_pressed)
	visibility_changed.connect(func():
		if is_visible:
			if remap_controls.is_empty():
				create_remap_controls()
	)
	%DeadzoneSlider.value = InputContext.input_controllers[input_controller_index].input_map.deadzone
	
func create_remap_controls() -> void:
	for action_name in DeviceInputMap.original_actions:
		var control : ActionRemapControl = button_remap_control_scene.instantiate()
		control.action_name = InputContext.input_controllers[input_controller_index].input_map.get_mapped_action(action_name)
		%ActionList.add_child(control)
		remap_controls.push_back(control)
	device_index_to_use = InputContext.input_controllers[input_controller_index].input_map.get_current_device_index()
	
func _on_reset_button_pressed() -> void:
	InputContext.input_controllers[input_controller_index].input_map.reset_all()
	device_index_to_use = input_controller_index
	%DeadzoneSlider.value = InputContext.input_controllers[input_controller_index].input_map.deadzone
	
func on_controller_selected_pressed(index: int):
	device_index_to_use = index

func _on_clear_button_pressed() -> void:
	InputContext.input_controllers[input_controller_index].input_map.clear_all()
	for child in remap_controls:
		child.render()



func _on_deadzone_slider_value_changed(value: float) -> void:
	InputContext.input_controllers[input_controller_index].input_map.set_deadzone(value)
