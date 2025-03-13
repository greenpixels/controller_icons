class_name NPCMiningBehavior
extends NPCBehavior


func physics_update(_delta: float) -> void:
	controller.movement_input = Vector2.ZERO
	
	if not is_instance_valid(controller.current_block_target):
		controller.behavior_machine.change_behavior("moving")
		controller.current_block_target = null
		return
	
	controller.look_at_input = controller.mining_raycast.global_position.direction_to(
		controller.current_block_target.global_position
	).normalized()
	controller.attacked.emit()
	
	if controller.minimum_time_before_behavior_change <= 0 and \
		controller.current_block_target.current_health == controller.last_block_health:
		controller.behavior_machine.change_behavior("moving")
	controller._play_move_and_idle_animation()
