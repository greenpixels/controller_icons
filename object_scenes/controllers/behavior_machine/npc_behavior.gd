class_name NPCBehavior
extends Node

var controller: HumanNpcController

func _ready() -> void:
	controller = get_parent().get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func can_transition_to(behavior: NPCBehavior):
	return true
