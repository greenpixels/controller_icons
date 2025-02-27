extends Node2D

func _ready() -> void:
	PlayersContext.spawn_players_at(self)
