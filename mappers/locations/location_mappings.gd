class_name LocationMappings 

const LOCATION_OVERWORLD_KEY = "LOCATION_OVERWORLD"
const LOCATION_OVERWORLD_PATH = "res://main_scenes/locations/_all/overworld/overworld.tscn"
const LOCATION_GOLD_CAVE_KEY = "LOCATION_GOLD_CAVE"
const LOCATION_GOLD_CAVE_PATH = "res://main_scenes/locations/cave/_all/gold_cave/gold_cave.tscn"
const LOCATION_IRON_CAVE_KEY = "LOCATION_IRON_CAVE"
const LOCATION_IRON_CAVE_PATH = "res://main_scenes/locations/cave/_all/iron_cave/iron_cave.tscn"

static var key_to_path: Dictionary[String, String] = {
	"LOCATION_OVERWORLD": "res://main_scenes/locations/_all/overworld/overworld.tscn",
	"LOCATION_GOLD_CAVE": "res://main_scenes/locations/cave/_all/gold_cave/gold_cave.tscn",
	"LOCATION_IRON_CAVE": "res://main_scenes/locations/cave/_all/iron_cave/iron_cave.tscn",
}

static var path_to_key: Dictionary[String, String] = {
	"res://main_scenes/locations/_all/overworld/overworld.tscn": "LOCATION_OVERWORLD",
	"res://main_scenes/locations/cave/_all/gold_cave/gold_cave.tscn": "LOCATION_GOLD_CAVE",
	"res://main_scenes/locations/cave/_all/iron_cave/iron_cave.tscn": "LOCATION_IRON_CAVE",
}
