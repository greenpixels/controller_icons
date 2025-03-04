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
var impact_intensity := 0. : 
	set(value):
		impact_intensity = value
		sprite.position = Vector2(randf_range(-impact_intensity, impact_intensity), randf_range(-impact_intensity, impact_intensity)) * SHAKE_FACTOR


var current_health : int 
func _ready() -> void:
	current_health = maximum_health
	%Shadow.texture = $Sprite2D.texture

func take_damage_from_item(source_item: Item):
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
	
func on_destroy():
	WorldContext.get_current_map().remove_block(self)
	if loot_table:
		loot_table.create_entries()
		if loot_table.entries.size() > 0:
			seed(hash(WorldContext.get_current_map().uuid + persistance.chunk_key + str(persistance.position_in_chunk_grid)))
			var loot : LootTableEntry = loot_table.pick_weighted_random()
			var pickup : ItemPickup = item_pickup_scene.instantiate()
			pickup.item = loot.object
			pickup.amount = randi_range(loot.min_amount, loot.max_amount)
			get_tree().current_scene.add_child.call_deferred(pickup)
			pickup.global_position = global_position
