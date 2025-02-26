extends Item
class_name Equipment
enum EquipmentSlot {
	HEAD,
	BODY,
	SHOES,
	RING
}

@export var slot : EquipmentSlot = EquipmentSlot.HEAD
