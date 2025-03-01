## This class dynamically maps input actions for a specific device by appending the device index to each action name.
## It uses a dictionary to map original action names to their device-specific versions.
## When initialized, it clones all existing input actions for the given device and ensures they are removed when the object is deleted.

extends RefCounted
class_name DeviceInputMap

## Stores the mapping between original action names and device-specific action names
var _action_map = {}
var _device_index = 0
var _device_overwrite = -1
const DEFAULT_DEADZONE = 0.15
var deadzone := DEFAULT_DEADZONE

static var original_actions : Array[StringName] = [
	"move_left", "move_right", "move_up", "move_down",
	"look_left", "look_right", "look_up", "look_down",
	"interact", "attack", "inventory",
	"ui_left", "ui_right", "ui_down", "ui_up",
	"cycle_item_left", "cycle_item_right"
]

## Initializes a new input map for a specific device using its index.
## Copies all existing actions and appends the device index to their names, allowing unique mappings per device.
func _init(device_index: int) -> void:
	_device_index = device_index
	var device_index_string = str(device_index)
	for action_name in original_actions:
		_clone_action_for_device(action_name, device_index_string)
	ControllerIcons.refresh()

## Clones an action for a specific device by appending the device index to its name.
func _clone_action_for_device(action_name: String, device_index_string: String) -> void:
	var action_events := InputMap.action_get_events(action_name)
	var new_action_name : String = action_name + "_" + device_index_string
	_action_map[action_name] = new_action_name
	InputMap.add_action(new_action_name)
	InputMap.action_set_deadzone(new_action_name, DEFAULT_DEADZONE)
	for event in action_events:
		var new_event = event.duplicate(true)
		_map_action_to_current_device(new_event)
		if _is_valid_event_for_device(new_event):
			InputMap.action_add_event(new_action_name, new_event)

## Checks if an event is valid for the current device.
func _is_valid_event_for_device(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion or _device_index == 0

## Resets a single action by removing its device-specific mapping
func reset_action(original_action: String, should_refresh := true) -> void:
	var mapped_action = get_mapped_action(original_action)
	if mapped_action == "none": return
	InputMap.action_erase_events(mapped_action)
	_reset_action_events(original_action, mapped_action)
	if should_refresh: ControllerIcons.refresh()

## Resets the events for a specific action.
func _reset_action_events(original_action: String, mapped_action: String) -> void:
	deadzone = DEFAULT_DEADZONE
	InputMap.action_set_deadzone(mapped_action, DEFAULT_DEADZONE)
	for original_event in InputMap.action_get_events(original_action):
		var new_event = original_event.duplicate(true)
		_map_action_to_current_device(new_event)
		if _is_valid_event_for_device(new_event):
			InputMap.action_add_event(mapped_action, new_event)

## Resets all actions by calling reset_action() for each entry in original_actions.
func reset_all() -> void:
	_device_overwrite = -1
	for action in original_actions:
		reset_action(action, false)
	ControllerIcons.refresh()

## Clears all actions by erasing their events.
func clear_all() -> void:
	for action in original_actions:
		var mapped_action = get_mapped_action(action)
		InputMap.action_erase_events(mapped_action)
	ControllerIcons.refresh()

## Sets the deadzone for all actions.
func set_deadzone(value: float):
	deadzone = value
	for original_action in original_actions:
		var mapped_action = get_mapped_action(original_action)
		InputMap.action_set_deadzone(mapped_action, deadzone)

## Overwrites the device index for all actions.
func overwrite_device(index : int):
	_device_overwrite = index
	for original_action in original_actions:
		var mapped_action = get_mapped_action(original_action)
		for event in InputMap.action_get_events(mapped_action):
			_map_action_to_current_device(event)
	ControllerIcons.refresh()

## Maps an action to the current device.
func _map_action_to_current_device(event: InputEvent):
	event.device = get_current_device_index()
	if event is not InputEventJoypadButton and event is not InputEventJoypadMotion:
		if _device_index == 0:
			event.device = 0

## Retrieves the mapped action name for a given original action name.
## Returns the device-specific action name if it exists, otherwise null.
func get_mapped_action(original_action: String) -> String:
	var mapped_action_name =  _action_map.get(original_action)
	if mapped_action_name != null: return mapped_action_name
	else:
		push_error("Action is not mapped:" + original_action)
		return "none"

## Cleans up all dynamically created actions when the object is about to be deleted.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(self):
		_cleanup_actions()

## Cleans up all dynamically created actions.
func _cleanup_actions() -> void:
	for original_action_name in _action_map.keys():
		var mapped_action_name = _action_map[original_action_name]
		InputMap.action_erase_events(mapped_action_name)
		InputMap.erase_action(mapped_action_name)
	_action_map.clear()

## Gets the current device index, considering any overwrites.
func get_current_device_index() -> int:
	return _device_overwrite if _device_overwrite >= 0 else _device_index
