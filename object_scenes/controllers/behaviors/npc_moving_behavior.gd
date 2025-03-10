class_name NPCMovingBehavior
extends NPCBehavior

func physics_update(_delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0 * controller.NOISE_SETTINGS.speed
	var noise_value = controller.noise.get_noise_1d(time) * controller.NOISE_SETTINGS.magnitude
	var target_direction = Vector2.from_angle(noise_value * TAU)
	
	if noise_value < controller.NOISE_SETTINGS.threshold and controller.minimum_time_before_behavior_change <= 0:
		controller.behavior_machine.change_behavior("idle")
		controller.movement_input = Vector2.ZERO
		return
		
	controller.movement_input = target_direction
	if controller.movement_input != Vector2.ZERO:
		controller.look_at_input = controller.movement_input
		
	controller.raycast.look_at(controller.raycast.global_position + controller.look_at_input.normalized())
	controller.raycast.force_raycast_update()
	
	if controller.raycast.is_colliding():
		var collider = controller.raycast.get_collider()
		if _check_for_minable_block(collider):
			controller.behavior_machine.change_behavior("mining")

func _check_for_minable_block(collider: Node) -> bool:
	if not collider is Block: return false
	if not (collider.minimal_axe_power >= 0 or collider.minimal_hammer_power >= 0 or collider.minimal_pickaxe_power >= 0):
		return false
		
	var current_item = controller.npc.inventory.items[controller.npc.current_item_index]
	if current_item == null or not current_item is Tool: return false
	
	if not current_item.axe_power >= collider.minimal_axe_power and \
		not current_item.pickaxe_power >= collider.minimal_pickaxe_power and \
		not current_item.hammer_power >= collider.minimal_hammer_power:
		return false
		
	controller.current_block_target = collider
	controller.last_block_health = collider.current_health
	return true
