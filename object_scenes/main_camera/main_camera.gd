extends Node2D
class_name MainCamera

static var detached := false
@onready var camera := $MainCamera

@export var min_zoom := 2.
@export var max_zoom := 0.4
@export var zoom_speed := 3.0
static var target_zoom_overwrite = null : 
	set(value):
		target_zoom_overwrite = value
var original_smoothing_speed : float
var smoothed_center := Vector2.ZERO
var original_camera_position : Vector2
var position_smoothing_speed := 2.
		
func _ready():
	smoothed_center = camera.global_position
	original_camera_position = camera.global_position
	original_smoothing_speed = position_smoothing_speed
	PlayersContext.players_spawned.connect(func():
		if PlayersContext.players.size() <= 0: return
		if not PlayersContext.players[0].is_inside_tree(): return
		camera.global_position = PlayersContext.players[0].global_position		
		smoothed_center = camera.global_position
	)
		
func _physics_process(_delta: float) -> void:
	handle_transition_state()
		
func _process(delta: float) -> void:
	handle_transition_state()
	update_camera_position(delta)
	update_camera_zoom(delta)

func handle_transition_state() -> void:
	if TransitionHandler.is_transitioning:
		position_smoothing_speed = 8
		if TransitionHandler._transition_time < 0.5:
			target_zoom_overwrite = 0.3
		else:
			target_zoom_overwrite = null
	else:
		position_smoothing_speed = original_smoothing_speed

func update_camera_position(delta: float) -> void:
	if PlayersContext.players.size() == 0:
		return

	var center = Vector2.ZERO
	var valid_players := 0.

	#camera.global_position = PlayersContext.players[0].global_position

	for player in PlayersContext.players:
		if is_instance_valid(player) and player.is_inside_tree():
			center += player.global_position
			valid_players += 1.
	
	if valid_players > 0:
		center /= valid_players
	elif PlayersContext.players.size() > 0:
		for player in PlayersContext.players:
			if is_instance_valid(player) and player.is_inside_tree():
				center = player.global_position
				break
	
	smoothed_center = smoothed_center.lerp(center, delta * position_smoothing_speed)
	
	if not MainCamera.detached:
		camera.global_position = smoothed_center

func update_camera_zoom(delta: float) -> void:
	var max_distance := 800.0
	
	for player in PlayersContext.players:
		if is_instance_valid(player) and player.is_inside_tree():
			for other_player in PlayersContext.players:
				if player != other_player and is_instance_valid(other_player) and other_player.is_inside_tree():
					max_distance = max(max_distance, player.position.distance_to(other_player.position))
	
	var distance_factor = max_distance / 1000.0
	var target_zoom = clamp(1.0 / (1.0 + distance_factor), 1. / min_zoom, 1./ max_zoom)

	if MainCamera.target_zoom_overwrite == null:
		camera.zoom = camera.zoom.lerp(Vector2.ONE * target_zoom, delta * zoom_speed)
	else:
		camera.zoom = camera.zoom.lerp(Vector2.ONE * target_zoom_overwrite, delta * zoom_speed)
