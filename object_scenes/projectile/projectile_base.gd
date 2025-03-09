extends Area2D
class_name Projectile

@onready var animated_sprite := $Sprite

var configuration : ProjectileConfiguration
var origin_node: Node = null
var origin_prev_pos: Vector2 = Vector2.ZERO

var source_item : Item
var damage: int
var direction_rad: float = 0.0
var current_lifetime := 0.

func _ready() -> void:
	current_lifetime = configuration.lifetime

	if configuration.should_face_direction:
		rotation = direction_rad

	# If anchoring to an origin, store its initial global position.
	if configuration.should_follow_origin_node and origin_node:
		origin_prev_pos = origin_node.global_position

	# Adjust animation speed to match the projectile lifetime if needed.
	if configuration.scale_animation_to_lifetime:
		var anim_name = animated_sprite.animation
		if anim_name != "":
			# Disable looping for this animation.
			animated_sprite.sprite_frames.set_animation_loop(anim_name, false)

			var frame_count = animated_sprite.sprite_frames.get_frame_count(anim_name)
			var base_fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
			if base_fps > 0 and configuration.lifetime > 0:
				# Scale so one full cycle lasts the entire lifetime.
				animated_sprite.speed_scale = float(frame_count) / (configuration.lifetime * base_fps)

	# Start playing the animation.
	animated_sprite.play()

func _physics_process(delta: float) -> void:
	rotation = direction_rad
	var projectile_displacement: Vector2 = Vector2.from_angle(direction_rad) * configuration.projectile_speed * delta
	
	var origin_displacement: Vector2 = Vector2.ZERO
	if configuration.should_follow_origin_node and origin_node:
		origin_displacement = origin_node.global_position - origin_prev_pos
		origin_prev_pos = origin_node.global_position

	var total_displacement: Vector2 = projectile_displacement + origin_displacement
	position += total_displacement
	# move_and_collide(total_displacement)
	
func _process(delta: float) -> void:
	current_lifetime -= delta
	if current_lifetime <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Block:
		if source_item and source_item is Weapon:
			body.take_damage_from_item(source_item)
	if body is CharacterBase and not body == origin_node:
		body.take_damage(self)
