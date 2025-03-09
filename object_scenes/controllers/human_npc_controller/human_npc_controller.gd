extends Controller
class_name HumanNpcController

# Constants
const ATTACK_RANGE: float = 110.0
const ATTACK_COOLDOWN: float = 0.5
const DEFAULT_BEHAVIOR_DURATION: float = 5.0
const NOISE_SETTINGS = {
	threshold = 0.025,  # Minimum noise magnitude
	speed = 0.25,      # Noise evolution speed
	magnitude = 5.0,    # Movement strength
	frequency = 0.2    # Noise frequency
}

# Nodes
@export var raycast: RayCast2D
@export var npc: Npc
@export var navigation_agent : NavigationAgent2D

var noise := FastNoiseLite.new()
var minimum_time_before_behavior_change: float = DEFAULT_BEHAVIOR_DURATION
var current_block_target: Block = null
var last_block_health: int = 0
var standstill_time_after_attack: float = 0.0
var current_character_target: CharacterBase = null

@onready var behavior_machine: BehaviorMachine = $BehaviorMachine

func _ready() -> void:
	# Initialize FastNoise parameters.
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = NOISE_SETTINGS.frequency
	behavior_machine.change_behavior("idle")

func _physics_process(delta: float) -> void:
	if standstill_time_after_attack > 0:
		standstill_time_after_attack -= delta
	if minimum_time_before_behavior_change > 0:
		minimum_time_before_behavior_change -= delta
	
	look_at_changed.emit(look_at_input)

func _on_behavior_changed(behavior_name: String) -> void:
	minimum_time_before_behavior_change = DEFAULT_BEHAVIOR_DURATION
	%BehaviorLabel.text = behavior_name.to_upper()


func _on_hurt(source: Projectile) -> void:
	if not source.origin_node or not source.origin_node is CharacterBase: return
	current_character_target = source.origin_node
	behavior_machine.change_behavior("fighting")
