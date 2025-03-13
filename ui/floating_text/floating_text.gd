extends Node2D
class_name FloatingText

@onready var label : RichTextLabel = $CenterContainer/RichTextLabel

@export var fade_time := 0.7
@export var scale_in_time := 0.8
@export var scale_out_time := 1.5
@export var vertical_move_distance := -500.
@export var vertical_move_duration := 1.
@export var content := ""
@export var vertical_spawn_offset := 0
var scale_multiplier := 1.
var global_text_position : Vector2

static func spawn_float_text(spawn_position: Vector2, text_content: String, parent: Node):
	var text : FloatingText = (load("res://ui/floating_text/floating_text.tscn") as PackedScene).instantiate()
	text.content = text_content
	text.global_text_position = spawn_position
	text.global_text_position.y += text.vertical_spawn_offset
	parent.add_child(text)
	text.call_deferred("_on_spawn")
	

func _on_spawn():
	global_position = global_text_position
	scale = Vector2.ZERO
	modulate = Color.WHITE
	label.text = content
	
	var fade_tween = TweenHelper.tween("fade_out", self)
	fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_time).set_ease(Tween.EASE_OUT).set_delay(0.2)
	fade_tween.tween_callback(queue_free)
	
	var move_tween = TweenHelper.tween("text_move", self)
	move_tween.tween_property(self, "global_position", global_text_position + Vector2(0, vertical_move_distance), vertical_move_duration).set_ease(Tween.EASE_IN_OUT)
	
	var scale_tween = TweenHelper.tween("text_scale", self)
	scale_tween.tween_property(self, "scale", Vector2.ONE * 6. * scale_multiplier, scale_in_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector2.ONE * scale_multiplier, 0.25)
	scale_tween.tween_property(self, "scale", Vector2.ZERO , scale_out_time/2.)
	
	
