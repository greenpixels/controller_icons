extends Node

var options_menu_scene := preload("res://ui/options_menu/options_menu.tscn")
var _menu : Control = null

signal listening_for_button_remap_changed(state: bool)

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("freeze_during_button_remap"):
		var callable = Callable(func(state): node_handle_button_remap_listening_change(node, state))
		listening_for_button_remap_changed.connect(callable)
		node.tree_exited.connect(func(): listening_for_button_remap_changed.disconnect(callable))

func node_handle_button_remap_listening_change(node: Node, state: bool):
	if is_instance_valid(node):
		node.set_process_input(!state)
		node.set_process(!state)
		node.set_process_shortcut_input(!state)

func _toggle_menu() -> void:
	if _menu:
		TweenHelper.tween("close", self).tween_callback(_menu.queue_free).set_delay(0.1)
		return
	for child in UiLayer.get_children():
		if child.is_in_group("popup"):
			return
	_menu = options_menu_scene.instantiate()
	UiLayer.add_child(_menu)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options") and not _menu and get_tree().current_scene is Location:
		_toggle_menu()
