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


func test_new_game_starts_with_the_machete_in_hand_and_no_save() -> void:
	assert_bool(_save.call("has_save")).is_false()
	var data: Dictionary = _save.get("data")
	assert_str(String(data["hotbar"][0])).is_equal("machete")
	assert_int(int(data["hand"])).is_equal(0)
	assert_str(String(data["armor"])).is_empty()
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


func test_old_save_keeps_its_respawn_in_the_first_area() -> void:
	# Jogo salvo da etapa 4: sem a área do ponto de retorno, sem santuários e sem elementos equipados.
	var old := {"version": 1, "respawn_point": "mine_entrance", "equipped": {"melee": "machete"}, "items": ["machete"], "killed": ["prologue_wolf"]}
	SaveFile.new(PATH).write(old)
	var reopened: Node = auto_free(load("res://autoload/save_system.gd").new())
	reopened.call("open", PATH)
	var data: Dictionary = reopened.get("data")
	assert_str(data["respawn_area"]).is_equal("res://world/areas/mine.tscn")
	assert_array(data["sanctuaries"]).is_empty()
	assert_array(data["equipped_elements"]).is_equal(["", ""])
	assert_int(int(data["version"])).is_equal(3)
	assert_str(String(data["hotbar"][0])).is_equal("machete")
	assert_bool(reopened.call("has_record", "killed", &"prologue_wolf")).is_true()


func test_version_2_equipment_becomes_the_hotbar() -> void:
	# A arma de perto e a de longe equipadas abrem a barra; a armadura continua vestida; as outras armas e a poção
	# entram na ordem em que foram achadas; a armadura guardada vai para a mochila.
	var old := {"version": 2, "respawn_point": "s1", "respawn_area": "res://world/areas/mine.tscn",
		"equipped": {"melee": "spear", "ranged": "slingshot", "armor": "miner_vest"},
		"items": ["machete", "slingshot", "miner_vest", "spear", "flask", "seal", "miner_armor", "pickaxe"]}
	SaveFile.new(PATH).write(old)
	var reopened: Node = auto_free(load("res://autoload/save_system.gd").new())
	reopened.call("open", PATH)
	var data: Dictionary = reopened.get("data")
	assert_array(data["hotbar"]).is_equal(["spear", "slingshot", "machete", "flask", "pickaxe"])
	assert_str(String(data["armor"])).is_equal("miner_vest")
	assert_array((data["bag"] as Array).filter(func(id: String) -> bool: return id != "")).is_equal(["miner_armor"])
	assert_bool(data.has("equipped")).is_false()


func test_new_game_has_no_respawn_area() -> void:
	assert_str(_save.get("data")["respawn_area"]).is_empty()
	assert_int(int(_save.get("data")["version"])).is_equal(3)
