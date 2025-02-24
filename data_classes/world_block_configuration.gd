extends Resource
class_name BlockSpawnConfiguration

# The block scene to instance.
@export var scene: PackedScene
# The chance weight for this block type.
@export var weight: float = 1.0
# The minimum grid distance from the spawn point for this block to appear.
@export var min_distance: float = 0.0
# The maximum grid distance from the spawn point at which this block can appear.
@export var max_distance: float = 1000.0
