extends CharacterBody2D
class_name CharacterBase

@onready var health_bar := %HealthBar
@onready var persistance: PersistanceCharacterState

const MAX_INVINCIBILITY_TIME := 0.15

var invinciblity_time := 0.
var knockback_force := Vector2.ZERO
var shake_force := 0.
var current_defense : int = 0
signal defense_changed(current_value : int)

func _update_health_bar():
	health_bar.current_health = persistance.current_health
	health_bar.maximum_health = persistance.maximum_health
	health_bar.visible = persistance.current_health < persistance.maximum_health

func take_damage(source: Projectile):
	if invinciblity_time > 0: return
	invinciblity_time = MAX_INVINCIBILITY_TIME
	persistance.current_health -= source.damage
	_update_health_bar()
	FloatingText.spawn_float_text(global_position, str(source.damage), get_tree().current_scene)
	
	if source.origin_node:
		knockback_force = source.origin_node.global_position.direction_to(self.global_position) * 400.
	shake_force = 32.
	%Sprite.modulate = Color.RED
	TweenHelper.tween("reduce_redness", self).tween_property(%Sprite, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_OUT)
	TweenHelper.tween("reduce_knockback", self).tween_property(self, "knockback_force", Vector2.ZERO, 0.1)
	TweenHelper.tween("reduce_shake", self).tween_property(self, "shake_force", 0., 0.5).set_ease(Tween.EASE_OUT)


func _on_equipment_items_changed() -> void:
	var previous_defense = current_defense
	current_defense = 0
	%Equipment.for_each_slot(func(item: Item, quantity: int):
		if item == null: return
		if "armor_value" in item and item is Armor:
			current_defense += item.armor_value	
	)
	if current_defense != previous_defense:
		defense_changed.emit(current_defense)
