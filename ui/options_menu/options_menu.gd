extends Panel

@onready var main_tab_container := $VBoxContainer/TabContainer
@onready var controller_tab_container := $VBoxContainer/TabContainer/CONTROLS/TabContainer
const TAB_CYCLE_COOLDOWN_MAX = 0.05
var tab_cycle_cooldown := 0.
func _on_button_pressed() -> void:
	OptionsContext._toggle_menu()

	


func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		OptionsContext._menu = null

func _process(delta: float) -> void:
	if tab_cycle_cooldown > 0: tab_cycle_cooldown -= delta

func _on_shortcut_button_ready() -> void:
	var back_button = $VBoxContainer/ShortcutButton
	back_button.button.grab_focus()


func _on_save_and_exit_button_pressed() -> void:
	for player in PlayersContext.players:
		player.persistance.copy_player_to_state(player)
		player.persistance.save_to_disk()
	PlayersContext.withdraw_players_from_scene()
	for player in PlayersContext.players:
		player.queue_free()
	PlayersContext.players = []
	WorldContext.world_state.save_to_disk()
	OptionsContext._toggle_menu()
	get_tree().change_scene_to_packed(load("res://main_scenes/main_menu/main_menu.tscn"))
