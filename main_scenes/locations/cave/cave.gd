extends Location

func _ready() -> void:
	PlayersContext.spawn_players_at(self)
