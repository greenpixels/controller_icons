@tool

extends Node2D

@export var maximum_health := 100. :
	set(value):
		maximum_health = value
		_update_health_bar()
@export var current_health := 0. :
	set(value):
		current_health = value
		_update_health_bar()
@onready var health_bar : ProgressBar = $HealthBar

var original_bg_color : Color
var original_border_color : Color

func _ready() -> void:
	var stylebox := health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	original_bg_color = stylebox.bg_color
	original_border_color = stylebox.border_color
	
func _update_health_bar():
	if not is_node_ready():
		await ready
	health_bar.value = clamp(current_health / maximum_health * 100., 0., 100.)
	var stylebox = (health_bar.get_theme_stylebox("fill") as StyleBoxFlat)
	
	stylebox.bg_color.h = original_bg_color.h + (100. - health_bar.value) / -340.
	stylebox.border_color.h = original_bg_color.h + (100. - health_bar.value) / -340.
