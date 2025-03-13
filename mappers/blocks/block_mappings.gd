class_name BlockMappings 

const BLOCK_BOUNDARY_KEY = "BLOCK_BOUNDARY"
const BLOCK_BOUNDARY_PATH = "res://object_scenes/blocks/_all/boundary/block_boundary.tscn"
const BLOCK_COPPER_KEY = "BLOCK_COPPER"
const BLOCK_COPPER_PATH = "res://object_scenes/blocks/_all/copper/block_copper.tscn"
const BLOCK_CRYSTAL_KEY = "BLOCK_CRYSTAL"
const BLOCK_CRYSTAL_PATH = "res://object_scenes/blocks/_all/crystal/block_crystal.tscn"
const BLOCK_DEAD_TREE_KEY = "BLOCK_DEAD_TREE"
const BLOCK_DEAD_TREE_PATH = "res://object_scenes/blocks/_all/dead_tree/block_dead_tree.tscn"
const BLOCK_DIRT_KEY = "BLOCK_DIRT"
const BLOCK_DIRT_PATH = "res://object_scenes/blocks/_all/dirt/block_dirt.tscn"
const BLOCK_GOLD_KEY = "BLOCK_GOLD"
const BLOCK_GOLD_PATH = "res://object_scenes/blocks/_all/gold/block_gold.tscn"
const BLOCK_IRON_KEY = "BLOCK_IRON"
const BLOCK_IRON_PATH = "res://object_scenes/blocks/_all/iron/block_iron.tscn"
const BLOCK_STONE_KEY = "BLOCK_STONE"
const BLOCK_STONE_PATH = "res://object_scenes/blocks/_all/stone/block_stone.tscn"
const BLOCK_CAVE_EXIT_KEY = "BLOCK_CAVE_EXIT"
const BLOCK_CAVE_EXIT_PATH = "res://object_scenes/blocks/interactable_blocks/_all/cave_exit/block_cave_exit.tscn"
const BLOCK_GOLD_CAVE_ENTRANCE_KEY = "BLOCK_GOLD_CAVE_ENTRANCE"
const BLOCK_GOLD_CAVE_ENTRANCE_PATH = "res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/gold_cave_entrance/block_gold_cave_entrance.tscn"
const BLOCK_IRON_CAVE_ENTRANCE_KEY = "BLOCK_IRON_CAVE_ENTRANCE"
const BLOCK_IRON_CAVE_ENTRANCE_PATH = "res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/iron_cave_entrance/block_iron_cave_entrance.tscn"

static var key_to_path: Dictionary[String, String] = {
	"BLOCK_BOUNDARY": "res://object_scenes/blocks/_all/boundary/block_boundary.tscn",
	"BLOCK_COPPER": "res://object_scenes/blocks/_all/copper/block_copper.tscn",
	"BLOCK_CRYSTAL": "res://object_scenes/blocks/_all/crystal/block_crystal.tscn",
	"BLOCK_DEAD_TREE": "res://object_scenes/blocks/_all/dead_tree/block_dead_tree.tscn",
	"BLOCK_DIRT": "res://object_scenes/blocks/_all/dirt/block_dirt.tscn",
	"BLOCK_GOLD": "res://object_scenes/blocks/_all/gold/block_gold.tscn",
	"BLOCK_IRON": "res://object_scenes/blocks/_all/iron/block_iron.tscn",
	"BLOCK_STONE": "res://object_scenes/blocks/_all/stone/block_stone.tscn",
	"BLOCK_CAVE_EXIT": "res://object_scenes/blocks/interactable_blocks/_all/cave_exit/block_cave_exit.tscn",
	"BLOCK_GOLD_CAVE_ENTRANCE": "res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/gold_cave_entrance/block_gold_cave_entrance.tscn",
	"BLOCK_IRON_CAVE_ENTRANCE": "res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/iron_cave_entrance/block_iron_cave_entrance.tscn",
}

static var path_to_key: Dictionary[String, String] = {
	"res://object_scenes/blocks/_all/boundary/block_boundary.tscn": "BLOCK_BOUNDARY",
	"res://object_scenes/blocks/_all/copper/block_copper.tscn": "BLOCK_COPPER",
	"res://object_scenes/blocks/_all/crystal/block_crystal.tscn": "BLOCK_CRYSTAL",
	"res://object_scenes/blocks/_all/dead_tree/block_dead_tree.tscn": "BLOCK_DEAD_TREE",
	"res://object_scenes/blocks/_all/dirt/block_dirt.tscn": "BLOCK_DIRT",
	"res://object_scenes/blocks/_all/gold/block_gold.tscn": "BLOCK_GOLD",
	"res://object_scenes/blocks/_all/iron/block_iron.tscn": "BLOCK_IRON",
	"res://object_scenes/blocks/_all/stone/block_stone.tscn": "BLOCK_STONE",
	"res://object_scenes/blocks/interactable_blocks/_all/cave_exit/block_cave_exit.tscn": "BLOCK_CAVE_EXIT",
	"res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/gold_cave_entrance/block_gold_cave_entrance.tscn": "BLOCK_GOLD_CAVE_ENTRANCE",
	"res://object_scenes/blocks/interactable_blocks/cave_entrance/_all/iron_cave_entrance/block_iron_cave_entrance.tscn": "BLOCK_IRON_CAVE_ENTRANCE",
}
