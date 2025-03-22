extends Area2D
class_name ItemPickup

@onready var line := $Line2D
@onready var sprite := $Sprite2D
@onready var label := %Label

@export var item : Item
@export var amount := 1
@export_storage var persistance : PersistanceItemPickupState
var original_position : Vector2
const PULL_DELAY_MAX = 0.75
var pull_to : CharacterBase = null :
	set(value):
		if pull_to != value:
			pull_delay = PULL_DELAY_MAX
		pull_to = value
		 
var pull_delay := 0.

func _ready() -> void:
	sprite.texture = item.texture
	original_position = sprite.position
	label.text = item.key
	
	# Genuinly fucked up that its not easier to make a gradient. Maybe I am missing something.
	# Why would the default have black and white
	# Why does clear_points not work
	# Why is it not possible for a gradient do not have any points
	line.gradient = Gradient.new()
	line.gradient.add_point(0, item.get_rarity_color())
	line.gradient.add_point(0, Color.TRANSPARENT)
	line.gradient.remove_point(0)
	line.gradient.remove_point(0)
	
	var pulse_tween = TweenHelper.tween("hover_effect", self)
	pulse_tween.set_loops(-1)
	
	pulse_tween.tween_property(sprite, "position", original_position  + Vector2(0, -3), 1) \
	.set_trans(Tween.TRANS_CIRC)
	
	pulse_tween.tween_property(sprite, "position", original_position, 1) \
	.set_trans(Tween.TRANS_CIRC)
	
func _process(delta: float) -> void:
	var previous_position = global_position
	if pull_to != null and pull_delay <= 0:
		var distance = global_position.distance_to(pull_to.global_position)
		if distance > 400:
			pull_to = null
			return
		var speed = clamp(150. / distance, .25, 200.)
		global_position = global_position.move_toward(pull_to.global_position, speed)
		
		if distance < 32:
			on_interact(pull_to)
	elif pull_delay > 0:
		pull_delay -= delta
	persistance.remaining_time_sec -= delta
	persistance.position = global_position
	if previous_position != global_position:
		_reassign_chunk_on_move()
		
	if persistance.remaining_time_sec <= 0:
		WorldContext.get_current_map().remove_item_pickup(self)
		queue_free()
	
func _reassign_chunk_on_move():
	var chunk_coord = WorldContext.calculate_base_chunk_coordinate(global_position)
	if str(chunk_coord) != persistance.chunk_key:
		if WorldContext.get_current_map().chunks.has(str(chunk_coord)):
			WorldContext.get_current_map().remove_item_pickup(self)
			WorldContext.get_current_map().chunks[str(chunk_coord)].item_pickups[persistance.uuid] = persistance
			persistance.chunk_key = str(chunk_coord)
			var chunk_node = get_tree().current_scene.get_node(WorldContext.get_chunk_node_name(chunk_coord))
			reparent(chunk_node)
		else:
			queue_free()
	
func on_interact(player: CharacterBase):
	var remaining = player.inventory.store_item(item, amount)
	amount = remaining
	if amount <= 0:
		WorldContext.get_current_map().remove_item_pickup(self)
		queue_free()
	else:
		pull_delay = PULL_DELAY_MAX
		pull_to = null
		
