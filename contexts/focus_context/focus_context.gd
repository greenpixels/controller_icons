extends Node

var current_focus : Control = null 

signal focus_changed(node: Control)

func _ready() -> void:
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
				check_for_focus()	
			)
			
			
			
				
			if node.focus_mode != Control.FOCUS_NONE:
				node.add_to_group("focusable")
				node.mouse_entered.connect(node.grab_focus)
				if not current_focus :
					node.grab_focus()
	)


func check_for_focus():
	if is_instance_valid(get_tree()) and not FocusContext.current_focus:
		var focusable_nodes = get_tree().get_nodes_in_group("focusable")
		for node in focusable_nodes as Array[Control]:
			if node.is_visible_in_tree():
				node.grab_focus()
