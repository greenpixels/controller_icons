extends Area2D
class_name ItemPickup

@onready var line := $Line2D
@onready var sprite := $Sprite2D
@onready var label := %Label

@export var item : Item
@export var amount := 1
var original_position : Vector2

func _ready() -> void:
	sprite.texture = item.texture
	original_position = sprite.position
	label.text = item.key
	
	# Genuinly fucked up that its not easier to make a gradient. Maybe I am missing something.
	# Why would the default it with black and white
	# Why does clear_points not work
	# Why is it not possible for a gradient do not have any points
	line.gradient = Gradient.new()
	line.gradient.add_point(0, item.get_rarity_color())
	line.gradient.add_point(0, Color.TRANSPARENT)
	line.gradient.remove_point(0)
	line.gradient.remove_point(0)
	
	var pulse_tween = TweenHelper.tween("hover_effect", self)
	pulse_tween.set_loops(-1)
	pulse_tween.tween_property(sprite, "position", original_position  + Vector2(0, -3), 1).set_trans(Tween.TRANS_CIRC)
	pulse_tween.tween_property(sprite, "position", original_position, 1).set_trans(Tween.TRANS_CIRC)
	
func on_interact(player: Player):
	var remaining = player.inventory.store_item(item, amount)
	amount = remaining
	if amount <= 0:
		queue_free()
