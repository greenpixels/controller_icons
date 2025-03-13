class_name NPCIdleBehavior
extends NPCBehavior


func physics_update(_delta: float) -> void:
	controller.npc.model.animation.play("idle")
	controller.movement_input = Vector2.ZERO
	if controller.minimum_time_before_behavior_change <= 0:
		controller.behavior_machine.change_behavior("moving")
