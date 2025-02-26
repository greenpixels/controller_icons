extends Node
class_name TabCycler

@export var TAB_CYCLE_COOLDOWN_MAX: float = 0.05
@export var tab_containers: Array[TabContainer] = []

static var tab_cycle_cooldown: float = 0.0
var _tab_containers: Array[TabContainer] = []

func _ready() -> void:
	# Resolve the NodePaths to actual TabContainer nodes
	for node in tab_containers:
		_tab_containers.append(node)

func _process(delta: float) -> void:
	if tab_cycle_cooldown > 0.0:
		tab_cycle_cooldown -= delta
		if tab_cycle_cooldown < 0.0:
			tab_cycle_cooldown = 0.0

func _input(event: InputEvent) -> void:
	if tab_cycle_cooldown > 0.0:
		return

	if Input.is_action_just_pressed("cycle_menu_left") and InputMap.event_is_action(event, "cycle_menu_left"):
		tab_cycle_cooldown = TAB_CYCLE_COOLDOWN_MAX
		change_tab_index(-1)
		return
	elif Input.is_action_just_pressed("cycle_menu_right") and InputMap.event_is_action(event, "cycle_menu_right"):
		tab_cycle_cooldown = TAB_CYCLE_COOLDOWN_MAX
		change_tab_index(1)
		return

	# Example block for ignoring certain UI focus or Sliders
	if FocusContext.current_focus and FocusContext.current_focus is Slider:
		return

	if Input.is_action_just_pressed("ui_left") and InputMap.event_is_action(event, "ui_left"):
		if not FocusContext.current_focus or not FocusContext.current_focus.find_valid_focus_neighbor(SIDE_LEFT):
			tab_cycle_cooldown = TAB_CYCLE_COOLDOWN_MAX
			change_tab_index(-1)
			return

	if Input.is_action_just_pressed("ui_right") and InputMap.event_is_action(event, "ui_right"):
		if not FocusContext.current_focus or not FocusContext.current_focus.find_valid_focus_neighbor(SIDE_RIGHT):
			tab_cycle_cooldown = TAB_CYCLE_COOLDOWN_MAX
			change_tab_index(1)
			return

func change_tab_index(amount: int) -> void:
	for i in range(_tab_containers.size() - 1, -1, -1):
		var container := _tab_containers[i]

		# Skip this container if it's not visible
		if not container.is_visible_in_tree():
			continue

		var old_index = container.current_tab
		container.current_tab += amount

		# If the TabContainer actually changed its current_tab, break out
		if container.current_tab != old_index:
			break
