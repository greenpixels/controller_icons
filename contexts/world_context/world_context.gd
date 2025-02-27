extends Node
@export var main_seed := 1234
var current_sub_seed := main_seed + 1

func set_sub_seed_by_block(block: Block):
	var sum_ab = block.global_position.x + block.global_position.y
	current_sub_seed = main_seed + ((sum_ab * (sum_ab + 1)) / 2) + block.global_position.y
