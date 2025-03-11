extends Resource
class_name BlockSpawnConfiguration

@export var scene: PackedScene
@export var weight: float = 1.0
@export var min_distance: float = 0.0
# If -1 or smaller then its unlimited
@export var max_distance: float = -1
@export var maximum_per_chunk : int = -1
