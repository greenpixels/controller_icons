extends Node
class_name InputController 

var device := 0
var movement_input := Vector2.ZERO
var look_at_input := Vector2.ZERO
var deadzone_treshhold := 0.1
var previos_mouse_position := Vector2.ZERO
var use_keyboard = false
var toolbar_offset_setter_delay := 0.
var toolbar_offset = 0 :
	set(value):
		if toolbar_offset_setter_delay > 0: return
		toolbar_offset_setter_delay = 0.2
		if value < 0: value = 2
		var new_offset = value % 3
		if new_offset != toolbar_offset:
			toolbar_offset = new_offset
			toolbar_offset_changed.emit(toolbar_offset)
		
signal look_at_changed(look_at: Vector2)
signal attack_pressed
signal interact_pressed
signal inventory_opened
signal toolbar_offset_changed(position: int)

func _process(delta: float) -> void:
	handle_movement_input()
	handle_look_at_input()
	if toolbar_offset_setter_delay > 0:
		toolbar_offset_setter_delay -= delta
		# Continuous attack input
	if use_keyboard:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			attack_pressed.emit()
	else:
		if Input.is_joy_button_pressed(device, JOY_BUTTON_X) or Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER):
			attack_pressed.emit()

func _input(event: InputEvent) -> void:
	if device == 0:
		# If any keyboard or mouse input is detected, use_keyboard becomes true.
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
			use_keyboard = true
		# If any controller input from device 0 is detected, use_keyboard is set to false.
		elif event is InputEventJoypadButton:
			if event.device == device:
				use_keyboard = false
		# For joypad motion events, check if the motion exceeds the deadzone threshold.
		elif event is InputEventJoypadMotion:
			if event.device == device and abs(event.axis_value) > deadzone_treshhold:
				use_keyboard = false

func handle_movement_input():
	movement_input = Vector2.ZERO
	if Input.get_connected_joypads().size() > device and not use_keyboard:
		movement_input.x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		movement_input.y = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
	elif device == 0 and use_keyboard:
		# The main player can always be controlled via keyboard
		movement_input.x = float(Input.is_action_pressed("move_right_main_player")) - float(Input.is_action_pressed("move_left_main_player"))
		movement_input.y = float(Input.is_action_pressed("move_down_main_player")) - float(Input.is_action_pressed("move_up_main_player"))
	
	movement_input = movement_input.clamp(-Vector2.ONE, Vector2.ONE)
	
	if abs(movement_input.x) < deadzone_treshhold: movement_input.x = 0
	if abs(movement_input.y) < deadzone_treshhold: movement_input.y = 0
	
func handle_look_at_input():
	var previous_look_at := look_at_input
	if Input.get_connected_joypads().size() > device and not use_keyboard:
		if abs(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)) > deadzone_treshhold or  abs(Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)) > deadzone_treshhold:
			look_at_input.x = Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
			look_at_input.y = Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
		else:
			look_at_input.x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
			look_at_input.y = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
			
	elif device == 0 and use_keyboard:
		look_at_input = get_parent().global_position.direction_to(get_parent().get_global_mouse_position())
	look_at_input = look_at_input.clamp(-Vector2.ONE, Vector2.ONE)
	
	if abs(look_at_input.x) < deadzone_treshhold: look_at_input.x = 0
	if abs(look_at_input.y) < deadzone_treshhold: look_at_input.y = 0
	if previous_look_at != look_at_input:
		look_at_changed.emit(look_at_input)

func _unhandled_input(event):
	if use_keyboard:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_DOWN:
					toolbar_offset += 1
				MOUSE_BUTTON_WHEEL_UP:
					toolbar_offset -= 1
		elif event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_E:
					interact_pressed.emit()
				KEY_B:
					inventory_opened.emit()
	else:
		if event is InputEventJoypadButton and event.device == device and event.pressed:
			match event.button_index:
				JOY_BUTTON_Y:
					interact_pressed.emit()
				JOY_BUTTON_BACK:
					inventory_opened.emit()
				JOY_BUTTON_DPAD_LEFT:
					toolbar_offset -= 1
				JOY_BUTTON_DPAD_RIGHT:
					toolbar_offset += 1


	
