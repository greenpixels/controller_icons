extends CharacterBody2D
class_name Player

@onready var controller : InputController = $InputController
@onready var animated_sprite := $AnimatedPlayerSprite
@onready var item := $Item
@onready var interact_radius := $InteractRadius
@onready var inventory : Storage = $Inventory
@onready var drop_table : WeightedList
var device_index := 0
const BASE_SPEED := 100
var last_horizontal_dir = 1

func _ready() -> void:
	item.item = inventory.items[controller.toolbar_offset]
	controller.device = device_index
	animated_sprite.material.set_shader_parameter("hue_shift", device_index * -30)

func _process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		animated_sprite.play("run")
		if abs(velocity.x) > 0:
			last_horizontal_dir = sign(velocity.x)
	else:
		animated_sprite.play("idle")
	animated_sprite.flip_h = controller.look_at_input.x < 0 if abs(controller.look_at_input.x) else last_horizontal_dir < 0
	item.position.x = 2 if animated_sprite.flip_h else -2
	if controller.look_at_input.length() <= 0.2:
		item.rotation = -0.66 * PI if animated_sprite.flip_h else -0.33 * PI

func _physics_process(_delta: float) -> void:
	velocity = controller.movement_input.normalized() * BASE_SPEED
	move_and_slide()

func _on_input_controller_look_at_changed(look_at: Vector2) -> void:
	item.rotation = look_at.angle()
	if abs(look_at.x) > 0:
		last_horizontal_dir = sign(look_at.x)
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


func _on_input_controller_toolbar_offset_changed(position: int) -> void:
	item.item = inventory.items[controller.toolbar_offset]	


func _on_inventory_items_changed() -> void:
	item.item = inventory.items[controller.toolbar_offset]	
