extends CharacterBase
class_name Npc

## NPC character implementation with movement, combat and inventory systems
## @desc Handles character movement, item management and combat interactions

# Constants
const BASE_SPEED: float = 400.0
const ANIMATION_BASE_SPEED: float = 1.2
const MAX_INVINCIBILITY_TIME: float = 0.15
const ITEM_OFFSET: float = 12.0

# Nodes
@onready var persistance: PersistanceCharacterState
@export var controller: Controller
@onready var held_item: HeldItem = %Item
@onready var inventory: Storage = $Inventory
@onready var equipment: Storage = $Equipment
@onready var model: HumanModel = %Model
@onready var original_item_position: Vector2

var current_item_index: int = 0
var last_horizontal_dir: float = 1.0
var previous_position: Vector2 = Vector2.ZERO
var invinciblity_time: float = 0.0
var knockback_force: Vector2 = Vector2.ZERO
var shake_force: float = 0.0

# Signals - using past tense for events that happened
signal hurt(source: Projectile)
signal position_changed(position: Vector2)

func _ready() -> void:
	original_item_position = held_item.position
	controller.attacked.connect(held_item._on_attacked)
	controller.look_at_changed.connect(_on_look_at_changed)
	controller.current_item_index_changed.connect(_on_current_item_changed)
	_on_inventory_items_changed()
	_on_equipment_items_changed()
	if persistance:
		persistance.copy_state_to_character(self)

func _process(delta: float) -> void:
	%Sprite.position = Vector2(randf() - 0.5, randf() - 0.5) * shake_force
	if invinciblity_time > 0:
		invinciblity_time -= delta
	model.scale.x = sign(controller.look_at_input.x) if abs(controller.look_at_input.x) > 0 else last_horizontal_dir
	held_item.position.x = original_item_position.x + ITEM_OFFSET if model.scale.x < 0 else original_item_position.x - ITEM_OFFSET
	if controller.look_at_input.length() <= 0.2:
		held_item.rotation = -0.66 * PI if model.scale.x < 0 else -0.33 * PI

func _physics_process(_delta: float) -> void:
	previous_position = global_position
	velocity += knockback_force
	if knockback_force.length() <= 0:
		velocity = controller.movement_input * BASE_SPEED
	
	move_and_slide()
	if previous_position.distance_to(global_position) > 1:
		model.animation.play("move")
		model.animation.speed_scale = controller.movement_input.length() * ANIMATION_BASE_SPEED
		if abs(velocity.x) > 0:
			last_horizontal_dir = sign(velocity.x)
	else:
		model.animation.play("idle")
	model.animation.speed_scale = ANIMATION_BASE_SPEED
	if global_position != previous_position:
		position_changed.emit(global_position)

func _on_look_at_changed(new_look_at: Vector2) -> void:
	held_item.rotation = new_look_at.angle()
	if abs(new_look_at.x) > 0:
		last_horizontal_dir = sign(new_look_at.x)

func _on_current_item_changed(_position: int) -> void:
	if inventory.items[_position] == null or not inventory.items[_position] is Weapon:
		for index in range(3):
			if inventory.items[index] is Weapon:
				controller.current_item_index = index
				return
		held_item.item = null
		return
	held_item.item = inventory.items[controller.current_item_index]

func _on_inventory_items_changed() -> void:
	held_item.item = inventory.items[current_item_index]
	_on_current_item_changed(current_item_index)

func _on_equipment_items_changed() -> void:
	model.update_sprite_from_human_style(persistance.human_style, equipment)
	
func _on_pickup_radius_area_entered(area: Area2D) -> void:
	if area is ItemPickup:
		if area.pull_to == null:
			area.pull_to = self
			
func take_damage(source: Projectile):
	if invinciblity_time > 0: return
	invinciblity_time = MAX_INVINCIBILITY_TIME
	persistance.current_health -= source.damage
	if source.origin_node:
		knockback_force = source.origin_node.global_position.direction_to(self.global_position) * 400.
	shake_force = 32.
	%Sprite.modulate = Color.RED
	TweenHelper.tween("reduce_redness", self).tween_property(%Sprite, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_OUT)
	TweenHelper.tween("reduce_knockback", self).tween_property(self, "knockback_force", Vector2.ZERO, 0.1)
	TweenHelper.tween("reduce_shake", self).tween_property(self, "shake_force", 0., 0.5).set_ease(Tween.EASE_OUT)
	hurt.emit(source)

func _on_moved(_position: Vector2) -> void:
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
	if str(chunk_coord) != persistance.chunk_key:
		if WorldContext.get_current_map().chunks.has(str(chunk_coord)):
			WorldContext.get_current_map().remove_npc(self)
			WorldContext.get_current_map().chunks[str(chunk_coord)].npcs[persistance.uuid] = persistance
			persistance.chunk_key = str(chunk_coord)
		else:
			queue_free()
	persistance.position = global_position
