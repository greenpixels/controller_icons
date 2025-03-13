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
	var direction_to_target = controller.npc.global_position.direction_to(
		controller.current_character_target.global_position
	)
	if controller.standstill_time_after_attack <= 0:
		var next_position = controller.navigation_agent.get_next_path_position()
		controller.movement_input = controller.npc.global_position.direction_to(next_position)
		if not controller.navigation_agent.is_target_reachable():
			controller.fight_target_raycast.look_at(controller.fight_target_raycast.global_position + direction_to_target.normalized())
			controller.fight_target_raycast.force_raycast_update()
			if controller.fight_target_raycast.is_colliding():
				if not controller.mining_raycast.get_collider() == controller.current_character_target:
					if controller.minimum_time_before_behavior_change <= 0:
						controller.behavior_machine.change_behavior("idle")
			else:
				controller.minimum_time_before_behavior_change = controller.DEFAULT_BEHAVIOR_DURATION
	
	controller.look_at_input = direction_to_target
	controller._play_move_and_idle_animation()


	if controller.npc.global_position.distance_to(
		controller.current_character_target.global_position
	) < controller.ATTACK_RANGE:
		controller.attacked.emit()
		controller.standstill_time_after_attack = controller.ATTACK_COOLDOWN
		controller.movement_input = Vector2.ZERO
