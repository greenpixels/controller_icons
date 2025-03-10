extends Node2D
class_name HumanModel

const HELMET_KEY := "helmet"
const TORSO_KEY := "torso"
const LEFT_FOOT_KEY := "left_foot"
const RIGHT_FOOT_KEY := "right_foot"
const FACE_KEY := "face"
const HAIR_KEY := "hair"

@onready var animation := $AnimationPlayer

@onready var helmet_sprite: Sprite2D = %HelmetSprite
@onready var torso_sprite: Sprite2D = %TorsoSprite
@onready var left_foot_sprite: Sprite2D = %LeftFootSprite
@onready var right_foot_sprite: Sprite2D = %RightFootSprite
@onready var face_sprite: Sprite2D = %FaceSprite
@onready var hair_sprite: Sprite2D = %HairSprite
@onready var head_sprite : Sprite2D = %HeadSprite

func update_sprite_from_human_style(human_style: PersistanceHumanStyle, equipment: Storage):
	var equipment_dict = {}
	if equipment != null:
		equipment_dict = {
			HELMET_KEY: ModelPartConfiguration.init(_get_texture_from_equipment_slot(PlayerInventory.ArmorSlotPositions.HELMET, equipment), Color.WHITE),
			TORSO_KEY: ModelPartConfiguration.init(_get_texture_from_equipment_slot(PlayerInventory.ArmorSlotPositions.BODY, equipment), Color.WHITE),
			LEFT_FOOT_KEY: ModelPartConfiguration.init(_get_texture_from_equipment_slot(PlayerInventory.ArmorSlotPositions.SHOES, equipment), Color.WHITE),
			RIGHT_FOOT_KEY: ModelPartConfiguration.init(_get_texture_from_equipment_slot(PlayerInventory.ArmorSlotPositions.SHOES, equipment), Color.WHITE)
		}
	var body_dict := {}
	if human_style != null:
		body_dict = {
			TORSO_KEY: ModelPartConfiguration.init(_get_model_texture_from_texture_key(human_style.torso_texture_key), human_style.torso_color),
			LEFT_FOOT_KEY: ModelPartConfiguration.init(_get_model_texture_from_texture_key(human_style.foot_texture_key), human_style.foot_color),
			RIGHT_FOOT_KEY: ModelPartConfiguration.init(_get_model_texture_from_texture_key(human_style.foot_texture_key), human_style.foot_color),
			FACE_KEY: ModelPartConfiguration.init(_get_model_texture_from_texture_key(human_style.face_texture_key), human_style.face_color),
			HAIR_KEY: ModelPartConfiguration.init(_get_model_texture_from_texture_key(human_style.hair_texture_key), human_style.hair_color)
		}
	update_sprites(body_dict, equipment_dict)
	
	hair_sprite.visible = (_get_armor(PlayerInventory.ArmorSlotPositions.HELMET, equipment) as Helmet).should_show_hair if _get_armor(PlayerInventory.ArmorSlotPositions.HELMET, equipment) != null else true
	head_sprite.visible = (_get_armor(PlayerInventory.ArmorSlotPositions.HELMET, equipment) as Helmet).should_show_base if _get_armor(PlayerInventory.ArmorSlotPositions.HELMET, equipment) != null else true
	#torso_sprite.visible = (_get_armor(PlayerInventory.ArmorSlotPositions.BODY, equipment) as Helmet).should_show_base if _get_armor(PlayerInventory.ArmorSlotPositions.BODY, equipment) != null else true
	#left_foot_sprite.visible = (_get_armor(PlayerInventory.ArmorSlotPositions.SHOES, equipment) as Helmet).should_show_base if _get_armor(PlayerInventory.ArmorSlotPositions.SHOES, equipment) != null else true
	#right_foot_sprite.visible = (_get_armor(PlayerInventory.ArmorSlotPositions.SHOES, equipment) as Helmet).should_show_base if _get_armor(PlayerInventory.ArmorSlotPositions.SHOES, equipment) != null else true
	
func _get_model_texture_from_texture_key(key: String) -> Texture:
	if key == null or key.is_empty():
		return null
	if not ModelTextureMappings.key_to_path.has(key):
		return null
	var path = ModelTextureMappings.key_to_path[key]
	return load(path) as Texture


func update_sprites(body_textures: Dictionary, equipment_textures: Dictionary) -> void:
	for key in [HELMET_KEY, TORSO_KEY, LEFT_FOOT_KEY, RIGHT_FOOT_KEY, FACE_KEY, HAIR_KEY]:
		if equipment_textures.has(key) and equipment_textures[key] != null and equipment_textures[key].texture != null:
			self[key + "_sprite"].texture = equipment_textures[key].texture
			self[key + "_sprite"].modulate = equipment_textures[key].color
		elif body_textures.has(key) and body_textures[key] != null and body_textures[key].texture != null:
			self[key + "_sprite"].texture = body_textures[key].texture
			self[key + "_sprite"].modulate = body_textures[key].color
		else:
			self[key + "_sprite"].texture = null
			match key:
				TORSO_KEY: self[key + "_sprite"].texture = load(ModelTextureMappings.BODY_DEFAULT)
				FACE_KEY: self[key + "_sprite"].texture = load(ModelTextureMappings.FACE_DEFAULT)
				LEFT_FOOT_KEY, RIGHT_FOOT_KEY: self[key + "_sprite"].texture = load(ModelTextureMappings.FOOT_DEFAULT)
			
			self[key + "_sprite"].modulate = Color.WHITE

func _get_texture_from_equipment_slot(slot: PlayerInventory.ArmorSlotPositions, equipment: Storage) -> Texture:
	return _get_armor(slot, equipment).armor_texture if _get_armor(slot, equipment) != null else null
		
func _get_armor(slot: PlayerInventory.ArmorSlotPositions, equipment: Storage) -> Armor:
	if equipment.items[slot] != null:
		if equipment.items[slot] is Armor:
			return (equipment.items[slot] as Armor)
		else:
			return null
	else:
		return null
