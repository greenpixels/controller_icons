extends StaticBody2D
class_name Block
@onready var sprite := $Sprite2D
@onready var item_pickup_scene := preload("res://object_scenes/item_pickup/item_pickup.tscn")

@export_storage var persistance : PersistanceBlockInformation
@export var key := "NO_KEY"
@export var should_use_uuid := false
@export var uuid : String = ""
@export var minimal_pickaxe_power := -1
@export var minimal_axe_power := -1
@export var minimal_hammer_power := -1
@export var maximum_health := 100
@export var loot_table : LootTable
const SHAKE_FACTOR := 16.
var current_health : int : 
	set(value):
		current_health = value
		if not is_node_ready() or not sprite.material: return
		sprite.material.set_shader_parameter("break_progress", 1. - float(current_health) / float(maximum_health))
var impact_intensity := 0. : 
	set(value):
		impact_intensity = value
		sprite.position = Vector2(randf_range(-impact_intensity, impact_intensity), randf_range(-impact_intensity, impact_intensity)) * SHAKE_FACTOR

signal on_added
signal on_removed

func _ready() -> void:
	%Shadow.texture = sprite.texture	

func take_damage_from_item(source_item: Item):
	if not source_item is Tool: return
	if minimal_axe_power >= 0 and source_item.axe_power >= minimal_axe_power and source_item.axe_power > 0:
		take_damage(source_item.axe_power)
	elif minimal_pickaxe_power >= 0 and source_item.pickaxe_power >= minimal_pickaxe_power and source_item.pickaxe_power > 0:
		take_damage(source_item.pickaxe_power)
	elif minimal_hammer_power >= 0 and source_item.hammer_power >= minimal_hammer_power and source_item.hammer_power > 0:
		take_damage(source_item.hammer_power)

func take_damage(amount: int):
	current_health -= amount
	impact_intensity = 1
	TweenHelper.tween("impact", self).tween_property(self, "impact_intensity", 0, 0.5)
	if current_health <= 0:
		on_destroy()
		queue_free()
		on_removed.emit()
	else:
		TweenHelper.tween("health_reset", self).tween_callback(func(): current_health = maximum_health).set_delay(1.5)
	
func on_destroy():
	if loot_table:
		loot_table.create_entries()
		if loot_table.entries.size() > 0:
			seed(hash(WorldContext.get_current_map().uuid + persistance.chunk_key + str(persistance.position_in_chunk_grid)))
			var loot : LootTableEntry = loot_table.pick_weighted_random()
			ItemContext.spawn_item_at(loot.object, global_position, randi_range(loot.min_amount, loot.max_amount))
	WorldContext.get_current_map().remove_block(self)

func _on_pool_get():
	on_added.emit()
	current_health = maximum_health
	
func _on_pool_return():
	for connection in get_signal_connection_list("on_added"):
		on_added.disconnect(connection.callable)
	for connection in get_signal_connection_list("on_removed"):
		on_removed.disconnect(connection.callable)
