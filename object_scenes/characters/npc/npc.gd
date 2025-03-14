extends CharacterBase
class_name Npc

## NPC character implementation with movement, combat and inventory systems
## @desc Handles character movement, item management and combat interactions

# Constants
const BASE_SPEED: float = 400.0
const ANIMATION_BASE_SPEED: float = 1.2
const ITEM_OFFSET: float = 12.0

# Nodes

@export var controller: HumanNpcController
@onready var held_item: HeldItem = %Item
@onready var inventory: Storage = $Inventory
@onready var equipment: Storage = $Equipment
@onready var model: HumanModel = %Model
@onready var original_item_position: Vector2

var current_item_index: int = 0
var last_horizontal_dir: float = 1.0
var previous_position: Vector2 = Vector2.ZERO

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
	var intended_velocity = Vector2.ZERO
	previous_position = global_position
	intended_velocity += knockback_force
	if knockback_force.length() <= 0:
		intended_velocity = controller.movement_input * BASE_SPEED

	velocity = intended_velocity
	move_and_slide()

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
	_update_health_bar()
	
func _on_pickup_radius_area_entered(area: Area2D) -> void:
	if area is ItemPickup:
		if area.pull_to == null:
			area.pull_to = self
			
func take_damage(source: Projectile):
	super(source)
	if persistance.current_health > 0:
		hurt.emit(source)
	else:
		equipment.drop_all(global_position)
		inventory.drop_all(global_position)
		if WorldContext.get_current_map().chunks.has(persistance.chunk_key):
			WorldContext.get_current_map().remove_npc(self)
		queue_free()

func _on_moved(_position: Vector2) -> void:
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
	if str(chunk_coord) != persistance.chunk_key:
		if WorldContext.get_current_map().chunks.has(str(chunk_coord)):
			WorldContext.get_current_map().remove_npc(self)
			WorldContext.get_current_map().chunks[str(chunk_coord)].npcs[persistance.uuid] = persistance
			persistance.chunk_key = str(chunk_coord)
			var has_chunk_node = get_tree().current_scene.has_node(WorldContext.get_chunk_node_name(chunk_coord))
			if not has_chunk_node:
				persistance.position = global_position
				queue_free()
				return
			else:
				var chunk_node = get_tree().current_scene.get_node(WorldContext.get_chunk_node_name(chunk_coord))
				reparent(chunk_node)
		else:
			global_position = previous_position
	persistance.position = global_position
