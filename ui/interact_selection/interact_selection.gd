extends NinePatchRect

func _ready() -> void:
	hide()

func activate(rect: Rect2):
	size = rect.size
	position = rect.position
	pivot_offset = rect.size / 2.
	scale = Vector2.ZERO
	TweenHelper.tween("scale", self).tween_property(self, "scale", Vector2.ONE * 1.2, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	show()

func deactivate():
	scale = Vector2.ZERO
	hide()
