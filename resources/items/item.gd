extends Resource
class_name Item

enum RARITY {
	JUNK,
	COMMON,
	RARE,
	VERY_RARE
}

@export var texture : AtlasTexture
@export var key := "NO_KEY"
@export var cooldown := 0.
@export var rarity := RARITY.COMMON
@export var max_stacks := 1

func get_rarity_color():
	match rarity:
		RARITY.JUNK: return Color.WEB_GRAY
		RARITY.COMMON: return Color.WHITE
		RARITY.RARE: return Color.DEEP_SKY_BLUE
		RARITY.VERY_RARE: return Color.ORANGE
