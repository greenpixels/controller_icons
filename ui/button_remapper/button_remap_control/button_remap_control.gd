extends HBoxContainer
class_name ActionRemapControl

var is_listening := false :
	set(value):
		is_listening = value
		OptionsContext.listening_for_button_remap_changed.emit(is_listening)
		%ActionName.text = "Listening ..." if is_listening else action_name.replace("_0", "").replace("_1", "").replace("_2", "").replace("_3", "")
		if not is_listening:
			TweenHelper.tween("prevent_off", self).tween_callback(func(): prevent_remapping = false).set_delay(0.1)
var prevent_remapping = false
var prevent_next_button_up = false
@export var action_name := "none"
var device_to_use := 0 : 
	set(value):
		device_to_use = value
		render()

func _ready() -> void:
	render()
	
func render():
	%ActionName.text = action_name.replace("_0", "").replace("_1", "").replace("_2", "").replace("_3", "")
	%KeyboardButton.texture = null
	%MouseButton.texture = null
	%JoypadButton.texture = null
	
	for event in InputMap.action_get_events(action_name):

		if event is InputEventKey:
			var icon = ControllerIconTexture.new()
			icon.path = action_name
			icon.force_type = ControllerIconTexture.ForceType.KEYBOARD_MOUSE
			%KeyboardButton.texture = icon
			
		elif event is InputEventMouseButton:
			var icon = ControllerIconTexture.new()
			icon.path = action_name
			icon.force_type = ControllerIconTexture.ForceType.KEYBOARD_MOUSE
			
			%MouseButton.texture = icon
			
		elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
			var icon = ControllerIconTexture.new()
			icon.force_type = ControllerIconTexture.ForceType.CONTROLLER
			icon.path = action_name
			icon.force_device = device_to_use
			%JoypadButton.texture = icon

func _input(event: InputEvent) -> void:
	if not is_listening or prevent_remapping: return
	var valid_remap = false;
	# event.device = device_to_use
	for original_event in InputMap.action_get_events(action_name):
		if event is InputEventKey and original_event is InputEventKey:
			InputMap.action_erase_event(action_name, original_event)
			valid_remap = true
		if event is InputEventMouseButton and original_event is InputEventMouseButton:
			InputMap.action_erase_event(action_name, original_event)
			valid_remap = true
		if event is InputEventJoypadButton and (original_event is InputEventJoypadMotion or original_event is InputEventJoypadButton):
			InputMap.action_erase_event(action_name, original_event)
			valid_remap = true
		if event is InputEventJoypadMotion and (original_event is InputEventJoypadMotion or original_event is InputEventJoypadButton):
			if abs((event as InputEventJoypadMotion).axis_value) >= 0.5:
				InputMap.action_erase_event(action_name, original_event)
				valid_remap = true

		if event is InputEventKey:
			InputMap.action_add_event(action_name, event)
		elif event is InputEventMouseButton:
			InputMap.action_add_event(action_name, event)
		elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
			InputMap.action_add_event(action_name, event)
		
		if valid_remap:
			prevent_remapping = true
			TweenHelper.tween("delay_off", self).tween_callback(func(): is_listening = false; ControllerIcons.refresh()).set_delay(0.1)
			render()
			
			


func _on_action_name_button_up() -> void:
	if prevent_next_button_up:
		prevent_next_button_up = false
		return
	TweenHelper.tween("delay_on", self).tween_callback(func(): is_listening = true).set_delay(0.1)


func _on_action_name_button_down() -> void:
	if is_listening:
		prevent_next_button_up = true
