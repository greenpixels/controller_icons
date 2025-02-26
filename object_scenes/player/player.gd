extends CharacterBody2D
class_name Player


@onready var controller : InputController
@onready var held_item := %Item
@onready var interact_radius := $InteractRadius
@onready var inventory : Storage = $Inventory
@onready var equipment : Storage = $Equipment
@onready var drop_table : WeightedList
@onready var player_model : PlayerModel = %PlayerModel
const BASE_SPEED := 400.
var last_horizontal_dir = 1
var player_index := 0
var previous_position := Vector2.ZERO
signal moved(position: Vector2)
const ANIMATION_BASE_SPEED := 1.2
@onready var original_item_position : Vector2
@onready var default_body_texture := preload("res://resources/items/equipment/armor/_assets/default_person.png")

func _ready() -> void:
	original_item_position = held_item.position
	controller.attack_pressed.connect(held_item._on_input_controller_attack_pressed)
	controller.interact_pressed.connect(_on_input_controller_interact_pressed)
	controller.inventory_opened.connect(_on_input_controller_inventory_opened)
	controller.look_at_changed.connect(_on_input_controller_look_at_changed)
	controller.toolbar_offset_changed.connect(_on_input_controller_toolbar_offset_changed)
	held_item.item = inventory.items[controller.toolbar_offset]
	inventory.store_item(load("res://resources/items/weapons/tools/_all/wooden_pickaxe.tres"), 1)
	inventory.store_item(load("res://resources/items/equipment/armor/_all/ominous_cap.tres"), 1)
	inventory.store_item(load("res://resources/items/equipment/armor/_all/ominous_robe.tres"), 1)

func _process(_delta: float) -> void:
	
		
	player_model.scale.x = sign(controller.look_at_input.x) if abs(controller.look_at_input.x) > 0 else last_horizontal_dir
	held_item.position.x = original_item_position.x + 12 if player_model.scale.x < 0 else original_item_position.x - 12
	if controller.look_at_input.length() <= 0.2:
		held_item.rotation = -0.66 * PI if player_model.scale.x <  0 else -0.33 * PI
	
	
	
	
func _physics_process(_delta: float) -> void:
	previous_position = global_position
	
		
	velocity = controller.movement_input * BASE_SPEED
	move_and_slide()
	
	if previous_position.distance_to(global_position) > 1:
		player_model.animation.play("move")
		player_model.animation.speed_scale = controller.movement_input.length() * ANIMATION_BASE_SPEED
		if abs(velocity.x) > 0:
			last_horizontal_dir = sign(velocity.x)
	else:
		player_model.animation.play("idle")
	
	player_model.animation.speed_scale = ANIMATION_BASE_SPEED
	if global_position != previous_position:
		moved.emit(global_position)
	
	

func _on_input_controller_look_at_changed(new_look_at: Vector2) -> void:
	held_item.rotation = new_look_at.angle()
	if abs(new_look_at.x) > 0:
		last_horizontal_dir = sign(new_look_at.x)
	queue_redraw()

func _on_input_controller_interact_pressed() -> void:
	pass
	#var closest_area = null
	#for area in interact_radius.get_overlapping_areas():
		#if area is ItemPickup:
			#if closest_area == null or area.global_position.distance_to(interact_radius.global_position) < closest_area.global_position.distance_to(interact_radius.global_position):
				#closest_area = area
	#if closest_area:
		#closest_area.on_interact(self)
	
func _on_input_controller_inventory_opened() -> void:
	inventory.open_view(func(inventory: PlayerInventory):
		inventory.equipment_storage = equipment
		inventory.player = self
	)


func _on_input_controller_toolbar_offset_changed(_position: int) -> void:
	if inventory.items[controller.toolbar_offset] == null or not inventory.items[controller.toolbar_offset]	is Weapon:
		for index in range(3):
			if inventory.items[index] is Weapon:
				controller.toolbar_offset = index
				return
		held_item.item = null
		return
	held_item.item = inventory.items[controller.toolbar_offset]	


func _on_inventory_items_changed() -> void:
	held_item.item = inventory.items[controller.toolbar_offset]
	_on_input_controller_toolbar_offset_changed(controller.toolbar_offset)

func _render_armor_for_slot(slot: PlayerInventory.ArmorSlotPositions, sprite_property: String):
	if equipment.items[slot] != null:
		(player_model[sprite_property].texture as AtlasTexture).atlas = (equipment.items[slot] as Armor).armor_set
	else:
		(player_model[sprite_property].texture as AtlasTexture).atlas = default_body_texture

func _on_equipment_items_changed() -> void:
	_render_armor_for_slot(PlayerInventory.ArmorSlotPositions.HELMET, "head_sprite")
	_render_armor_for_slot(PlayerInventory.ArmorSlotPositions.BODY, "torso_sprite")
	_render_armor_for_slot(PlayerInventory.ArmorSlotPositions.SHOES, "left_foot_sprite")
	_render_armor_for_slot(PlayerInventory.ArmorSlotPositions.SHOES, "right_foot_sprite")


func _on_interact_radius_area_entered(area: Area2D) -> void:
	if area is ItemPickup:
		if area.pull_to == null:
			area.pull_to = self
