extends Node2D
class_name HeldItem

@onready var animation_player := $AnimationPlayer
@onready var item_sprite := %ItemSprite
@export var item : Item :
	set(value):
		item = value
		handle_item_change(item)
		
@export var player : Player
var current_cooldown := 0.

func handle_item_change(new_item: Item):
	if not is_node_ready(): return
	visible = item != null
	if item == null:
		return
	item_sprite.texture = new_item.texture

func _process(delta: float) -> void:
	if not item: return
	scale.y = 1 if player.player_model.scale.x < 0 == false else -1
	# item_sprite.scale.x = 1 if Vector2.from_angle(rotation).x > 0 else -1
	if current_cooldown > 0:
		current_cooldown -= delta
	if current_cooldown < 0:
		current_cooldown = 0

func trigger():
	if not item or item.cooldown == 0: return
	if item is Weapon:
		if item.projectile_scene and item.projectile_configuration:
			var projectile : Projectile = item.projectile_scene.instantiate()
			projectile.direction_rad = rotation
			projectile.origin_node = player
			projectile.configuration = item.projectile_configuration
			projectile.source_item = item
			get_tree().current_scene.add_child(projectile)
			projectile.animated_sprite.flip_v = scale.y < 0
			projectile.global_position = player.global_position + Vector2.from_angle(rotation) * item.projectile_configuration.projectile_spawn_offset
			

func _on_input_controller_attack_pressed() -> void:
	if not item or item.cooldown == 0: return
	if current_cooldown <= 0:
		current_cooldown = item.cooldown
		animation_player.stop()
		var anim_name = "melee"
		var anim = animation_player.get_animation(anim_name)
		if anim:
			var anim_length = anim.length
			if item.cooldown < anim_length:
				animation_player.speed_scale = anim_length / item.cooldown
			else:
				animation_player.speed_scale = 1.0
		animation_player.play(anim_name)
