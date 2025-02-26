extends Panel

@onready var main_tab_container := $VBoxContainer/TabContainer
@onready var controller_tab_container := $VBoxContainer/TabContainer/CONTROLS/TabContainer
@onready var player_toggles := [%PlayerToggle_1, %PlayerToggle_2, %PlayerToggle_3, %PlayerToggle_4]
const TAB_CYCLE_COOLDOWN_MAX = 0.05
var tab_cycle_cooldown := 0.
func _on_button_pressed() -> void:
	OptionsContext._toggle_menu()

func _ready() -> void:
	PlayersContext.players_changed.connect(handle_player_change)
	tree_exited.connect(func(): PlayersContext.players_changed.disconnect(handle_player_change))
	handle_player_change()
	
func handle_player_change():
	var index = 0
	for toggle in player_toggles as Array[Button]:
		if PlayersContext.check_player_exists(index):
			toggle.text = "REMOVE PLAYER " + str(index + 1)
		else:
			toggle.text = "ADD PLAYER " + str(index + 1)
		index += 1

func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		OptionsContext._menu = null

func _process(delta: float) -> void:
	if tab_cycle_cooldown > 0: tab_cycle_cooldown -= delta


func _on_player_toggle_2_pressed() -> void:
	if not PlayersContext.check_player_exists(1):
		PlayersContext.add_new_player(1)
	else:
		PlayersContext.remove_player(1)


func _on_player_toggle_3_pressed() -> void:
	if not PlayersContext.check_player_exists(2):
		PlayersContext.add_new_player(2)
	else:
		PlayersContext.remove_player(2)


func _on_player_toggle_4_pressed() -> void:
	if not PlayersContext.check_player_exists(3):
		PlayersContext.add_new_player(3)
	else:
		PlayersContext.remove_player(3)
