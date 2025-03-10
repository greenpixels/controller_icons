extends Node

var current_focus : Control = null 

signal focus_changed(node: Control)

func _enter_tree() -> void:
	get_tree().node_added.connect(func(node):
		if node is Control:
			node.focus_entered.connect(func():
				current_focus = node
				focus_changed.emit(node)
			)
			node.focus_exited.connect(func():
				if current_focus == node:
					current_focus = null
			)
			node.visibility_changed.connect(func():
				if not current_focus == null and not current_focus.is_visible_in_tree():
					current_focus = null
				Debounce.debounce("focus_check",check_for_focus, 0.1, false)
			)
				
			if node.focus_mode == Control.FOCUS_ALL:
				node.add_to_group("focusable")
				node.mouse_entered.connect(node.grab_focus)
				if not current_focus :
					node.grab_focus()
	)
	# get_tree().tree_changed.connect(Debounce.debounce.bind("focus_check", check_for_focus, 0.1, false))


func check_for_focus():
	if not is_instance_valid(get_tree()) or not is_instance_valid(get_viewport()): return
	if get_tree().get_node_count_in_group("popup") > 0:
		if FocusContext.current_focus != null:
			var parent = FocusContext.current_focus.get_parent()
			while parent != null:
				if parent.is_in_group("popup"):
					return
				parent = parent.get_parent()
		for focusable in get_tree().get_nodes_in_group("focusable"):
			if not (focusable as Control).is_visible_in_tree(): continue
			var parent = focusable.get_parent()
			while parent != null:
				if parent.is_in_group("popup"):
					focusable.grab_focus()
					return
				parent = parent.get_parent()
		
	if FocusContext.current_focus == null and get_viewport().gui_get_focus_owner():
		FocusContext.current_focus = get_viewport().gui_get_focus_owner()
		return 
	if is_instance_valid(get_tree()) and not FocusContext.current_focus:
		var focusable_nodes = get_tree().get_nodes_in_group("focusable")
		for node in focusable_nodes as Array[Control]:
			if node.is_visible_in_tree():
				node.grab_focus()
