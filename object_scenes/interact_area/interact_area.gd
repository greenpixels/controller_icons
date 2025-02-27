extends Area2D
class_name InteractArea

signal interacted

var _is_focused := false :
	set(value):
		_is_focused = value
		if _is_focused:
			$InteractSelection.activate(($InteractShape.shape as RectangleShape2D).get_rect())
		else:
			$InteractSelection.deactivate()

func _ready() -> void:
	PlayersContext.players_interact_focus_changed.connect(func():
		_is_focused = PlayersContext.players_interact_focus.any(func(focus_target): return focus_target == self)
	)

func on_interact():
	interacted.emit()

func _handle_interact():
	if not _is_focused: return
	on_interact()
