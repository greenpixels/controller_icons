class_name NPCFightingBehavior
extends NPCBehavior

func physics_update(_delta: float) -> void:
	if not is_instance_valid(controller.current_character_target) or \
		controller.current_character_target.persistance.current_health <= 0:
		controller.current_character_target = null
		controller.behavior_machine.change_behavior("moving")
		return

	controller.movement_input = Vector2.ZERO
	controller.navigation_agent.set_target_position(controller.current_character_target.global_position)	
	
	if controller.standstill_time_after_attack <= 0:
		var next_position = controller.navigation_agent.get_next_path_position()
		controller.movement_input = controller.npc.global_position.direction_to(next_position)

	controller.look_at_input = controller.npc.global_position.direction_to(
		controller.current_character_target.global_position
	)

	if controller.npc.global_position.distance_to(
		controller.current_character_target.global_position
	) < controller.ATTACK_RANGE:
		controller.attacked.emit()
		controller.standstill_time_after_attack = controller.ATTACK_COOLDOWN
		controller.movement_input = Vector2.ZERO
