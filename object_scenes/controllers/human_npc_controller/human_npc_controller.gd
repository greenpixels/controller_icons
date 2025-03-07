extends Controller
class_name HumanNpcController

# Define a simple state machine for the NPC.
enum State {
	IDLE,
	MOVING,
	MINING
}

# The raycast node that scans in the look_at_input direction.
@export var raycast: RayCast2D
@export var npc : Npc
var noise := FastNoiseLite.new()
# NPC state and noise parameters.ds
var current_state: int = State.IDLE :
	set(value):
		if current_state == value: return
		current_state = value
		minimum_time_before_state_change = 5.
		
var noise_threshold: float = 0.025  # Minimum noise magnitude to trigger movement.
var noise_speed: float = 0.25        # Speed factor for noise evolution.
var noise_magnitude: float = 5.0    # Overall movement strength from noise.
var minimum_time_before_state_change = 3.
var current_block_target : Block = null
var last_block_health : int = 0

func _ready() -> void:
	# Initialize FastNoise parameters.
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.2

func state_mining():
	movement_input = Vector2.ZERO
	
	
	if not is_instance_valid(current_block_target):
		current_state = State.MOVING
		return
	
	look_at_input = raycast.global_position.direction_to(current_block_target.global_position).normalized()
	attacked.emit()
	
	if minimum_time_before_state_change <= 0 and current_block_target.current_health == last_block_health:
		current_state = State.MOVING
		return

func state_idle():
	if minimum_time_before_state_change <= 0:
		current_state = State.MOVING
		return
	
func state_moving():
	var time = Time.get_ticks_msec() / 1000. * noise_speed
	var noise_value = noise.get_noise_1d(time) * noise_magnitude
	var target_direction = Vector2.from_angle(noise_value * TAU * 1.)
	
	if noise_value < noise_threshold and minimum_time_before_state_change <= 0:
		current_state = State.IDLE
		movement_input = Vector2.ZERO
		return 
		
	movement_input = target_direction
	if movement_input != Vector2.ZERO:
		look_at_input = movement_input
		
	var ray_direction = look_at_input
	raycast.look_at(raycast.global_position + ray_direction.normalized())
	raycast.force_raycast_update()
	
	# --- Scan for Blocks ---
	# If the raycast collides with something, check if it is of type Block.
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is Block:
			if collider.minimal_axe_power >= 0 or collider.minimal_hammer_power >= 0 or collider.minimal_pickaxe_power >= 0:
				var current_item = npc.inventory.items[npc.current_item_index]
				if current_item == null: return
				if current_item is Tool: 
					## TODO: Move away from blocks we can't break
					if not current_item.axe_power >=  collider.minimal_axe_power and \
						not current_item.pickaxe_power >=  collider.minimal_pickaxe_power and \
						not current_item.hammer_power >=  collider.minimal_hammer_power:
							return
					current_state = State.MINING
					current_block_target = collider
					last_block_health = collider.current_health
					return

func _process(delta: float) -> void:
	if minimum_time_before_state_change > 0:
		minimum_time_before_state_change -= delta
		
	match(current_state):
		State.MOVING: state_moving()
		State.IDLE: state_idle()
		State.MINING: state_mining()
	
	look_at_changed.emit(look_at_input)
