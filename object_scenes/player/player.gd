extends CharacterBody2D
class_name Player


@onready var controller : InputController
@onready var animated_sprite := $AnimatedPlayerSprite
@onready var held_item := $Item
@onready var interact_radius := $InteractRadius
@onready var inventory : Storage = $Inventory
@onready var drop_table : WeightedList
const BASE_SPEED := 400.
var last_horizontal_dir = 1
var player_index := 0
var previous_position := Vector2.ZERO
signal moved(position: Vector2)

func _ready() -> void:
	controller.attack_pressed.connect(held_item._on_input_controller_attack_pressed)
	controller.interact_pressed.connect(_on_input_controller_interact_pressed)
	controller.inventory_opened.connect(_on_input_controller_inventory_opened)
	controller.look_at_changed.connect(_on_input_controller_look_at_changed)
	controller.toolbar_offset_changed.connect(_on_input_controller_toolbar_offset_changed)
	held_item.item = inventory.items[controller.toolbar_offset]
	inventory.store_item(load("res://resources/items/weapons/tools/_all/wooden_pickaxe.tres"), 1)

func _process(_delta: float) -> void:
	if velocity != Vector2.ZERO:
		animated_sprite.play("run")
		if abs(velocity.x) > 0:
			last_horizontal_dir = sign(velocity.x)
	else:
		animated_sprite.play("idle")
	animated_sprite.flip_h = controller.look_at_input.x < 0 if abs(controller.look_at_input.x) else last_horizontal_dir < 0
	held_item.position.x = 12 if animated_sprite.flip_h else -12
	if controller.look_at_input.length() <= 0.2:
		held_item.rotation = -0.66 * PI if animated_sprite.flip_h else -0.33 * PI
	
	if global_position != previous_position:
		moved.emit(global_position)
	var previous_position = global_position
func _physics_process(_delta: float) -> void:
	if controller.movement_input.length() > 1:
		controller.movement_input = controller.movement_input.normalized()
	velocity = controller.movement_input * BASE_SPEED
	move_and_slide()
	

func _on_input_controller_look_at_changed(new_look_at: Vector2) -> void:
	held_item.rotation = new_look_at.angle()
	if abs(new_look_at.x) > 0:
		last_horizontal_dir = sign(new_look_at.x)
	queue_redraw()

func _draw() -> void:
	if controller.look_at_input.length() > 0.5 and not controller.use_keyboard:
		draw_circle(controller.look_at_input * 50., 5, Color.RED)

func _on_input_controller_interact_pressed() -> void:
	var closest_area = null
	for area in interact_radius.get_overlapping_areas():
		if area is ItemPickup:
			if closest_area == null or area.global_position.distance_to(interact_radius.global_position) < closest_area.global_position.distance_to(interact_radius.global_position):
				closest_area = area
	if closest_area:
		closest_area.on_interact(self)
	
func _on_input_controller_inventory_opened() -> void:
	inventory.open_view()


func _on_input_controller_toolbar_offset_changed(_position: int) -> void:
	held_item.item = inventory.items[controller.toolbar_offset]	


func _on_inventory_items_changed() -> void:
	held_item.item = inventory.items[controller.toolbar_offset]	
