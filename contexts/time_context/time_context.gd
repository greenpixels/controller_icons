extends Node

var time_blocking_nodes := 0 :
	set(value):
		time_blocking_nodes = value
		get_tree().paused = time_blocking_nodes > 0

var time := 0.

func _ready() -> void:
	get_tree().node_added.connect(func(node : Node):
		if node.is_in_group("time_blocking"):
			time_blocking_nodes += 1
	)
	get_tree().node_removed.connect(func(node : Node):
		if node.is_in_group("time_blocking"):
			time_blocking_nodes -= 1
	)

func _process(delta: float) -> void:
	if not get_tree().paused:
		time += delta
