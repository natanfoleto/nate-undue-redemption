extends Node
## Grava e lê o jogo salvo (12-tecnico): JSON na pasta do usuário, regravado a cada conquista e a cada descanso.
## Tudo o que é salvo tem um identificador único no mapa. As opções ficam em outro arquivo.

const PATH := "user://save.json"
const VERSION := 1

## Listas de identificadores que o jogo guarda.
const KILLED := "killed"
const OPENED := "opened"
const ITEMS := "items"
const ELEMENTS := "elements"
const UPGRADES := "upgrades"
const MURALS := "murals"

var data: Dictionary = {}

var _file := SaveFile.new(PATH)


func _ready() -> void:
	open(PATH)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_died.connect(_on_player_died)


## Abre um arquivo de jogo salvo; sem ele, começa um jogo novo. Os testes usam outro arquivo.
func open(path: String) -> void:
	_file = SaveFile.new(path)
	# Um jogo salvo de uma versão anterior ganha os campos que faltam, com os valores de um jogo novo.
	var fresh := _new_game()
	data = fresh.merged(_file.read(), true)
	data["equipped"] = (fresh["equipped"] as Dictionary).merged(data["equipped"], true)


## Se já existe um jogo salvo, para o menu mostrar "Continuar".
func has_save() -> bool:
	return _file.exists()


## Começa do zero: apaga o jogo salvo.
func new_game() -> void:
	_file.erase()
	data = _new_game()


func save() -> void:
	var error := _file.write(data)
	if error != OK:
		push_error("Não deu para gravar o jogo salvo: %s" % error_string(error))


## Guarda uma conquista (inimigo morto, item, atalho, mural) e grava na hora.
func record(list: String, id: StringName) -> void:
	if id == &"" or has_record(list, id):
		return
	(data[list] as Array).append(String(id))
	save()


func has_record(list: String, id: StringName) -> bool:
	return String(id) in (data.get(list, []) as Array)


func _on_enemy_died(enemy: Node3D) -> void:
	var id: StringName = enemy.get(&"save_id") if &"save_id" in enemy else &""
	record(KILLED, id)


func _on_player_died() -> void:
	data["deaths"] = int(data.get("deaths", 0)) + 1
	save()


# Nate começa com o facão, sem armadura (05-itens).
static func _new_game() -> Dictionary:
	return {
		"version": VERSION,
		"respawn_point": "",
		"equipped": {"melee": "machete"},
		KILLED: [],
		OPENED: [],
		ITEMS: ["machete"],
		ELEMENTS: [],
		UPGRADES: [],
		MURALS: [],
		"play_time": 0.0,
		"deaths": 0,
	}
