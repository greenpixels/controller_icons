## A tooltip management system for displaying contextual descriptions.
##
## This class handles tooltip appearance, animations, and BBCode formatting for highlighted keys.
## It dynamically positions tooltips based on the origin node and viewport.
extends CanvasLayer

@onready var layout_wrapper = %LayoutWrapper
@onready var tooltip_container = %TooltipContainer
@onready var main_tooltip = %MainTooltip
@onready var tooltip_loading_bar = %TooltipLoadingBar
@onready var tooltip_scene = preload("res://ui/tooltip_component/tooltip/tooltip.tscn")
@export var highlighted_keys : Array[TooltipHighlightedKey]
@export var explanations_delay = 1.25
@export var tooltip_transition_type : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var tooltip_easing_type : Tween.EaseType = Tween.EASE_OUT
var explanations : Array[Node] = []

## Initializes the tooltip system and connects concealment signals to tooltip triggers.
func _ready():
	layout_wrapper.scale = Vector2(0, 1)
	get_tree().node_added.connect(
		func(node):
			if node is Control:
				var already_connected = false
				for connection in (node.focus_exited as Signal).get_connections():
					if connection.callable.get_method() == conceal.get_method():
						already_connected = true
				if not already_connected:
					node.focus_exited.connect(conceal)
	)

## Hides the tooltip with an animated transition.
func conceal():
	TweenHelper.tween("tooltip_container_scale", layout_wrapper).tween_property(layout_wrapper, "scale", Vector2(0, 1), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## Displays a tooltip with the given content.
##
## @param origin_node The control node from which the tooltip originates.
## @param content The text content to display in the tooltip.
## @param show_extra_explanation Whether to show additional explanation content.
func describe(origin_node: Control, content: String, show_extra_explanation = false):
	
	var viewport_center_position = get_viewport().get_visible_rect().size.x / 2
	tooltip_loading_bar.value = 0
	TweenHelper.tween("load_progress", tooltip_loading_bar).tween_property(tooltip_loading_bar, "value", 0, 0)
	__cleanup()
	main_tooltip.set_description(apply_bbcode_for_common_keys(content, show_extra_explanation))
	if not explanations.is_empty():
		TweenHelper.tween("load_progress", tooltip_loading_bar).tween_property(tooltip_loading_bar, "value", 100, explanations_delay)

	for explanation in explanations:
		var current_modulate = explanation.modulate
		explanation.modulate.a = 0
		TweenHelper.tween("fade_in", explanation).tween_property(explanation, "modulate", current_modulate, 0.15).set_delay(explanations_delay)
		
	var origin_x_position = 0
	if origin_node:
		origin_x_position = origin_node.global_position.x
	if origin_x_position > viewport_center_position:
		layout_wrapper.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_KEEP_WIDTH)
	else:
		layout_wrapper.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_KEEP_WIDTH)
	tooltip_container.scale = Vector2(1, 1)
	layout_wrapper.scale = Vector2(0,1)
	TweenHelper.tween("tooltip_container_scale", layout_wrapper).tween_property(layout_wrapper, "scale", Vector2(1, 1), 0.25).set_trans(tooltip_transition_type).set_ease(tooltip_easing_type)

## Applies BBCode formatting to highlighted keys in the content.
##
## @param content The text content to process.
## @param show_explanations Whether explanations should be included for highlighted keys.
## @returns A BBCode-formatted string.
func apply_bbcode_for_common_keys(content: String, show_explanations: bool) -> String:
	if show_explanations:
		for highlighted_key in highlighted_keys:
			if highlighted_key.explanation:
				content = add_explanation(content, "{" + highlighted_key.key + "}", highlighted_key.explanation.explanation_tr_key, highlighted_key.explanation.should_remove_key)

	for highlighted_key in highlighted_keys:
		var replacement_bbcode_builder : BBCodeHelper = BBCodeHelper.build(tr(highlighted_key.tr_key).capitalize())
		if highlighted_key.icon:
			replacement_bbcode_builder = replacement_bbcode_builder.add_icon(highlighted_key.icon)
		replacement_bbcode_builder.color("#" + highlighted_key.color.to_html(true))
		content = content.format({highlighted_key.key: replacement_bbcode_builder.result()})
	content.strip_edges()

	return content

## Adds an explanation tooltip for a key within the content.
##
## @param current_content The content string where the key appears.
## @param key_to_replace The key that should be replaced by an explanation.
## @param explanation The explanation text to display.
## @param should_remove_key If `true`, the key will be removed from the final content.
## @param title Optional title for the explanation.
## @returns The updated content string.
func add_explanation(current_content: String, key_to_replace: StringName, explanation: String, should_remove_key = false, title: String = "") -> String:
	if not current_content.contains(key_to_replace): return current_content
	if title.is_empty(): title = key_to_replace
	var popover : Control = tooltip_scene.instantiate()
	popover.set_description(
		apply_bbcode_for_common_keys(title, false) +
		"\n\n" +
		apply_bbcode_for_common_keys(explanation, false)
	)
	
	explanations.push_back(popover)
	tooltip_container.add_child(popover)
	tooltip_container.move_child(popover, 0)
	if should_remove_key: current_content = current_content.replace(key_to_replace, "")
	return current_content

## Cleans up and removes all active explanation tooltips.
func __cleanup():
	for node in explanations:
		node.queue_free()
	explanations = []
