class_name SaveFile
extends RefCounted
## O arquivo do jogo salvo (12-tecnico): JSON, com gravação segura. O jogo escreve num arquivo temporário e só
## no fim o troca pelo antigo, que vira a cópia de segurança até a gravação seguinte.
## Os números voltam do JSON como float.

var path: String


func _init(file_path: String) -> void:
	path = file_path


## Grava os dados. Só troca o arquivo depois de conferir que o temporário ficou inteiro.
func write(data: Dictionary) -> Error:
	var text := JSON.stringify(data, "\t")
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.close()
	if FileAccess.get_file_as_string(temporary) != text:
		return ERR_FILE_CORRUPT
	var backup := path + ".bak"
	if FileAccess.file_exists(path):
		_remove(backup)
		var moved := DirAccess.rename_absolute(path, backup)
		if moved != OK:
			return moved
	# A cópia fica até a próxima gravação: sem como forçar o disco, um desligamento logo depois
	# ainda pode estragar o arquivo novo.
	return DirAccess.rename_absolute(temporary, path)


## Lê os dados. Sem arquivo bom, tenta a cópia de segurança; sem nenhum, devolve vazio (jogo novo).
func read() -> Dictionary:
	var data := _read_file(path)
	if data.is_empty():
		data = _read_file(path + ".bak")
	return data


func exists() -> bool:
	return not read().is_empty()


## Apaga o jogo salvo ("Novo jogo"). As opções ficam em outro arquivo.
func erase() -> void:
	for file_path in [path, path + ".tmp", path + ".bak"]:
		_remove(file_path)


static func _read_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	return parsed if parsed is Dictionary else {}


static func _remove(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
