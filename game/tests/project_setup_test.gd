extends GdUnitTestSuite
## Confere a montagem do projeto: botões do 04-player e tabela de tradução (etapa 0 do 13-plano-de-producao).

const PLAYER_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"aim_up", &"aim_down", &"aim_left", &"aim_right",
	&"attack", &"use_hold", &"hotbar_1", &"hotbar_2", &"hotbar_3", &"hotbar_4", &"hotbar_5", &"hotbar_next",
	&"hotbar_previous", &"dodge", &"spell_1", &"spell_2", &"interact", &"murals", &"inventory", &"pause",
]

# No teclado e mouse, a mira segue o cursor: as ações de mira só existem no analógico.
const CONTROLLER_ONLY_ACTIONS: Array[StringName] = [&"aim_up", &"aim_down", &"aim_left", &"aim_right"]
# No controle, o direcional passa pelos espaços da barra um a um: os números só existem no teclado.
const KEYBOARD_ONLY_ACTIONS: Array[StringName] = [&"hotbar_1", &"hotbar_2", &"hotbar_3", &"hotbar_4", &"hotbar_5"]


func test_every_action_works_on_controller() -> void:
	var missing := PLAYER_ACTIONS.filter(func(action: StringName) -> bool:
		return action not in KEYBOARD_ONLY_ACTIONS and not _has_event(action, _is_controller_event))
	assert_array(missing).is_empty()


func test_every_action_works_on_keyboard_and_mouse() -> void:
	var missing := PLAYER_ACTIONS.filter(func(action: StringName) -> bool:
		return action not in CONTROLLER_ONLY_ACTIONS and not _has_event(action, _is_keyboard_mouse_event))
	assert_array(missing).is_empty()


func test_game_title_comes_from_translation() -> void:
	assert_str(tr(&"GAME_TITLE")).is_equal("Nate: Undue Redemption")


func _has_event(action: StringName, matches: Callable) -> bool:
	return InputMap.has_action(action) and InputMap.action_get_events(action).any(matches)


func _is_controller_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion


func _is_keyboard_mouse_event(event: InputEvent) -> bool:
	return event is InputEventKey or event is InputEventMouseButton
