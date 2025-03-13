extends CharacterBody2D
class_name CharacterBase

@onready var health_bar := %HealthBar

func _update_health_bar(persistance : PersistanceCharacterState):
	health_bar.current_health = persistance.current_health
	health_bar.maximum_health = persistance.maximum_health
	health_bar.visible = persistance.current_health < persistance.maximum_health
