extends CharacterBody2D
class_name CharacterBase

const BASE_SPEED := 400.
const ANIMATION_BASE_SPEED := 1.2

@onready var persistance : PersistanceCharacterState
@export var controller: Controller
@onready var held_item : HeldItem = %Item
@onready var inventory: Storage = $Inventory
@onready var equipment: Storage = $Equipment
@onready var model: HumanModel = %Model
@onready var original_item_position: Vector2

var current_item_index = 0
var last_horizontal_dir = 1
var previous_position := Vector2.ZERO

signal moved(position: Vector2)

func _ready() -> void:
	original_item_position = held_item.position
	controller.attacked.connect(held_item._on_attacked)
	controller.look_at_changed.connect(_on_look_at_changed)
	controller.current_item_index_changed.connect(_on_current_item_changed)
	_on_inventory_items_changed()
	_on_equipment_items_changed()
	if persistance:
		persistance.copy_state_to_character(self)

func _process(_delta: float) -> void:
	model.scale.x = sign(controller.look_at_input.x) if abs(controller.look_at_input.x) > 0 else last_horizontal_dir
	held_item.position.x = original_item_position.x + 12 if model.scale.x < 0 else original_item_position.x - 12
	if controller.look_at_input.length() <= 0.2:
		held_item.rotation = -0.66 * PI if model.scale.x < 0 else -0.33 * PI

func _physics_process(_delta: float) -> void:
	previous_position = global_position
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
		moved.emit(global_position)

func _on_look_at_changed(new_look_at: Vector2) -> void:
	held_item.rotation = new_look_at.angle()
	if abs(new_look_at.x) > 0:
		last_horizontal_dir = sign(new_look_at.x)
	#queue_redraw()


func _on_current_item_changed(position: int) -> void:
	if inventory.items[position] == null or not inventory.items[position] is Weapon:
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
