class_name BehaviorMachine
extends Node

signal behavior_changed(behavior_name: String)

var current_behavior: NPCBehavior = null
var behaviors: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is NPCBehavior:
			behaviors[child.name.to_lower()] = child

func change_behavior(new_behavior_name: String) -> void:
	if not behaviors.has(new_behavior_name.to_lower()):
		push_warning("Behavior %s not found" % new_behavior_name)
		return
		
	var new_behavior = behaviors[new_behavior_name.to_lower()]
	if current_behavior and not current_behavior.can_transition_to(new_behavior):
		return
		
	if current_behavior:
		current_behavior.exit()
		
	current_behavior = new_behavior
	current_behavior.enter()
	behavior_changed.emit(new_behavior_name)

func _physics_process(delta: float) -> void:
	if current_behavior:
		current_behavior.physics_update(delta)

func _process(delta: float) -> void:
	if current_behavior:
		current_behavior.update(delta)
