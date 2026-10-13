extends GdUnitTestSuite
## Gravação segura do jogo salvo (12-tecnico).

const FOLDER := "user://test_saves"

var _file: SaveFile


func before_test() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	_file = SaveFile.new(FOLDER.path_join("save.json"))
	_file.erase()


func after_test() -> void:
	_file.erase()


func test_writes_and_reads_back_the_same_data() -> void:
	var data := {"last_sanctuary": "bosque_1", "killed": ["mina_lobo_1", "mina_lobo_2"], "deaths": 3}
	assert_int(_file.write(data)).is_equal(OK)
	assert_str(_json(_file.read())).is_equal(_json(data))


func test_keeps_the_previous_save_as_backup() -> void:
	_file.write({"deaths": 0})
	_file.write({"deaths": 1})
	assert_bool(FileAccess.file_exists(_file.path + ".tmp")).is_false()
	assert_str(_json(SaveFile.new(_file.path + ".bak").read())).is_equal(_json({"deaths": 0}))
	assert_str(_json(_file.read())).is_equal(_json({"deaths": 1}))


func test_without_a_file_is_a_new_game() -> void:
	assert_bool(_file.exists()).is_false()
	assert_dict(_file.read()).is_empty()


func test_broken_file_falls_back_to_the_backup() -> void:
	# O computador desligou depois de guardar a cópia e antes de trocar o arquivo.
	_file.write({"deaths": 2})
	DirAccess.rename_absolute(_file.path, _file.path + ".bak")
	var broken := FileAccess.open(_file.path, FileAccess.WRITE)
	broken.store_string("{\"deaths\": 3, ")
	broken.close()
	assert_str(_json(_file.read())).is_equal(_json({"deaths": 2}))


func test_erase_removes_every_copy() -> void:
	_file.write({"deaths": 1})
	_file.erase()
	assert_bool(_file.exists()).is_false()


# Compara pelo texto do JSON relido: o JSON devolve os números como float.
func _json(data: Dictionary) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(data)), "", true)
