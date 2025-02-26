extends Node2D

@onready var camera := $MainCamera

# Customize these values to tweak the zoom behavior
@export var min_zoom := 2. # Closest zoom (most zoomed in)
@export var max_zoom := 0.4 # Farthest zoom (most zoomed out)
@export var zoom_speed := 3.0  # Speed of zoom transition

func _physics_process(delta: float) -> void:
	if PlayersContext.players.size() == 0:
		return  # Avoid division by zero if there are no players

	var center = Vector2(0, 0)
	var max_distance := 800.

	# Sum all player positions and find the maximum distance
	for player in PlayersContext.players:
		center += player.position
		for other_player in PlayersContext.players:
			if player != other_player:
				var distance = player.position.distance_to(other_player.position)
				max_distance = max(max_distance, distance)

	# Calculate the average position
	center /= PlayersContext.players.size()

	# Set this node's position to the center point
	position = center

	# Invert the zoom calculation: the further apart, the smaller the zoom factor (zooms out)
	var distance_factor = max_distance / 1000.0
	var target_zoom = clamp(1.0 / (1.0 + distance_factor), 1. / min_zoom, 1./ max_zoom)

	# Apply smooth zoom
	camera.zoom = camera.zoom.lerp(Vector2(target_zoom, target_zoom), delta * zoom_speed)
