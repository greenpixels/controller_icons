extends Node2D

@onready var input_controllers : Array[InputController] = [$InputController1, $InputController2, $InputController3, $InputController4]

func _ready() -> void:
	var index := 0
	for input_controller in input_controllers:
		input_controller.device = index
		input_controller.init_device_map()
		index += 1
