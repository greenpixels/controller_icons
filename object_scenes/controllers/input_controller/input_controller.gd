extends Controller
class_name InputController 

signal interacted
signal inventory_opened

var offset_change_delay := 0.
var OFFSET_CHANGE_DELAY_MAY := 0.25
var device := 0
var deadzone_treshhold := 0.1
var previos_mouse_position := Vector2.ZERO
var use_keyboard = false :
	set(value):
		use_keyboard = value
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if not use_keyboard else Input.MOUSE_MODE_VISIBLE)

var input_map : DeviceInputMap

func init_device_map() -> void:
	input_map = DeviceInputMap.new(device)
	
func _process(delta: float) -> void:
	handle_movement_input()
	handle_look_at_input()
	handle_button_input()
	if offset_change_delay >= 0:
		offset_change_delay -= delta

func _input(event: InputEvent) -> void:
	if device == 0:
		# If any keyboard or mouse input is detected, use_keyboard becomes true.
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
			use_keyboard = true
		# If any controller input from device 0 is detected, use_keyboard is set to false.
		elif event is InputEventJoypadButton:
			if event.device == input_map.get_current_device_index():
				use_keyboard = false
		# For joypad motion events, check if the motion exceeds the deadzone threshold.
		elif event is InputEventJoypadMotion:
			if event.device == input_map.get_current_device_index() and abs(event.axis_value) > deadzone_treshhold:
				use_keyboard = false

func handle_movement_input():
	movement_input.x = Input.get_axis(input_map.get_mapped_action("move_left"), input_map.get_mapped_action("move_right"))
	movement_input.y = Input.get_axis(input_map.get_mapped_action("move_up"), input_map.get_mapped_action("move_down"))
	if movement_input.length() > 1:
		movement_input = movement_input.normalized()
		
	
func handle_look_at_input():
	var previous_look_at := look_at_input
	if Input.get_action_strength(input_map.get_mapped_action("look_right")) or \
	   Input.get_action_strength(input_map.get_mapped_action("look_left")) or \
	   Input.get_action_strength(input_map.get_mapped_action("look_up")) or \
	   Input.get_action_strength(input_map.get_mapped_action("look_down")):
		
		look_at_input.x = Input.get_action_strength(input_map.get_mapped_action("look_right")) - \
						  Input.get_action_strength(input_map.get_mapped_action("look_left"))
		look_at_input.y = Input.get_action_strength(input_map.get_mapped_action("look_down")) - \
						  Input.get_action_strength(input_map.get_mapped_action("look_up"))
	else:
		look_at_input.x = Input.get_action_strength(input_map.get_mapped_action("move_right")) - \
						  Input.get_action_strength(input_map.get_mapped_action("move_left"))
		look_at_input.y = Input.get_action_strength(input_map.get_mapped_action("move_down")) - \
						  Input.get_action_strength(input_map.get_mapped_action("move_up"))

	if PlayersContext.players.size() > 0 and device == 0 and use_keyboard:
		# Handle mouse-based look input
		var player = PlayersContext.players[0]
		if player and player.is_inside_tree():
			look_at_input = player.global_position.direction_to(player.get_global_mouse_position())
			

	# Emit signal if the look input has changed
	if previous_look_at != look_at_input:
		look_at_changed.emit(look_at_input)

func handle_button_input():
	if Input.get_action_strength(input_map.get_mapped_action("attack")):
		attacked.emit()
	if Input.is_action_just_pressed(input_map.get_mapped_action("interact")):
		interacted.emit()
	if Input.is_action_just_pressed(input_map.get_mapped_action("inventory")):
		inventory_opened.emit()
	if Input.is_action_just_pressed(input_map.get_mapped_action("cycle_item_left")):
		if offset_change_delay <= 0:
			current_item_index -= 1
			offset_change_delay = OFFSET_CHANGE_DELAY_MAY
	if Input.is_action_just_pressed(input_map.get_mapped_action("cycle_item_right")):
		if offset_change_delay <= 0:
			current_item_index += 1
			offset_change_delay = OFFSET_CHANGE_DELAY_MAY



	
