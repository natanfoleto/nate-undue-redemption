extends GdUnitTestSuite
## Salvamento a cada conquista (02-core-loop, 12-tecnico): o que foi conquistado volta ao abrir o jogo.

const PATH := "user://test_saves/save_system.json"

var _save: Node


func before_test() -> void:
	DirAccess.make_dir_recursive_absolute("user://test_saves")
	_save = auto_free(load("res://autoload/save_system.gd").new())
	_save.call("open", PATH)
	_save.call("new_game")


func after_test() -> void:
	SaveFile.new(PATH).erase()


func test_new_game_starts_with_the_machete_and_no_save() -> void:
	assert_bool(_save.call("has_save")).is_false()
	var data: Dictionary = _save.get("data")
	assert_str(String(data["equipped"]["melee"])).is_equal("machete")
	assert_array(data["items"]).contains(["machete"])


func test_a_conquest_is_saved_at_once() -> void:
	_save.call("record", "killed", &"mine_wolf_1")
	assert_bool(_save.call("has_save")).is_true()
	var reopened: Node = auto_free(load("res://autoload/save_system.gd").new())
	reopened.call("open", PATH)
	assert_bool(reopened.call("has_record", "killed", &"mine_wolf_1")).is_true()
	assert_bool(reopened.call("has_record", "killed", &"mine_wolf_2")).is_false()


func test_the_same_conquest_is_kept_once() -> void:
	_save.call("record", "opened", &"mine_chest_vest")
	_save.call("record", "opened", &"mine_chest_vest")
	assert_array(_save.get("data")["opened"]).has_size(1)


func test_objects_without_id_are_not_saved() -> void:
	_save.call("record", "killed", &"")
	assert_array(_save.get("data")["killed"]).is_empty()


func test_deaths_are_counted_for_the_end_summary() -> void:
	_save.call("_on_player_died")
	_save.call("_on_player_died")
	var reopened: Node = auto_free(load("res://autoload/save_system.gd").new())
	reopened.call("open", PATH)
	assert_int(int(reopened.get("data")["deaths"])).is_equal(2)


func test_new_game_erases_the_save() -> void:
	_save.call("record", "killed", &"mine_wolf_1")
	_save.call("new_game")
	assert_bool(_save.call("has_save")).is_false()
	assert_bool(_save.call("has_record", "killed", &"mine_wolf_1")).is_false()
