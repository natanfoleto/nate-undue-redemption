extends Node
## Grava e lê o jogo salvo (12-tecnico): JSON na pasta do usuário, regravado a cada conquista e a cada descanso.
## Tudo o que é salvo tem um identificador único no mapa. As opções ficam em outro arquivo.

const PATH := "user://save.json"
## Versão do formato. A 2 (etapa 5) guarda a área do ponto de retorno; a 3, a barra fixa, a mochila e a armadura no
## lugar do equipamento; a 4 troca o facão pela espada e tira os itens que saíram do jogo; a 5 deixa só duas
## armaduras (o Colete vira o Manto, e a Armadura de minerador sai).
const VERSION := 5
## Em cada versão, os itens que mudaram de nome e os que saíram do jogo.
const ITEM_CHANGES := {
	4: {"renamed": {"machete": "sword"}, "removed": ["pickaxe", "tacape", "stone_blade", "blowgun", "javelin"]},
	5: {"renamed": {"miner_vest": "fiber_cloak"}, "removed": ["miner_armor"]},
}
## Dicas que voltam na versão 4: o tiro e a poção mudaram de botão.
const RELEARNED_HINTS: Array[String] = ["HINT_SHOOT", "HINT_FLASK"]
## Objetos do mapa com identificador novo na versão 5: o baú da Mina guarda o Manto.
const RENAMED_OPENED := {"mine_chest_vest": "mine_chest_cloak"}
## A primeira área do jogo: na versão 1, todo ponto de retorno ficava nela.
const FIRST_AREA := "res://world/areas/mine.tscn"

## Listas de identificadores que o jogo guarda.
const KILLED := "killed"
const OPENED := "opened"
const ITEMS := "items"
const ELEMENTS := "elements"
const UPGRADES := "upgrades"
const MURALS := "murals"
const SANCTUARIES := "sanctuaries"

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
	_migrate()


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


# Fechar o jogo funciona como uma morte (02-core-loop): tudo já está salvo; grava só o tempo de jogo.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and get_tree().current_scene is AreaLevel:
		save()


# Jogo salvo da versão 1: o ponto de retorno ainda não guardava a área, e todos ficavam na Mina. Da versão 2: as
# armas equipadas abrem a barra, a armadura continua vestida e os outros itens vão para os primeiros lugares livres.
# Das versões 3 e 4: os itens que mudaram de nome e os que saíram do jogo (antes de tudo, para a barra já sair certa).
func _migrate() -> void:
	var version := int(data.get("version", 1))
	if version < 2 and data.get("respawn_point", "") != "" and data.get("respawn_area", "") == "":
		data["respawn_area"] = FIRST_AREA
	if version < 4:
		_migrate_items(4)
		data["hints"] = (data.get("hints", []) as Array).filter(func(key: String) -> bool: return key not in RELEARNED_HINTS)
	if version < 5:
		_migrate_items(5)
		data[OPENED] = (data.get(OPENED, []) as Array).map(func(id: String) -> String: return RENAMED_OPENED.get(id, id))
	if version < 3:
		var equipped: Dictionary = data.get("equipped", {})
		data["hotbar"] = [equipped.get("melee", ""), equipped.get("ranged", "")].filter(func(id: String) -> bool: return id != "")
		data["bag"] = []
		data["armor"] = equipped.get("armor", "")
		data["hand"] = 0
		data.erase("equipped")
		for id: String in data[ITEMS]:
			ItemPlaces.place(data, id)
	data["version"] = VERSION


# Para a versão dada: os itens que mudaram de nome trocam de nome e os que saíram somem da lista, do equipamento
# antigo, da armadura vestida, da barra e da mochila; um item que já existia com o nome novo não fica repetido. A
# mochila fica sem buracos, e a mão que estava num item que saiu passa para o primeiro item da barra.
func _migrate_items(to_version: int) -> void:
	var changes: Dictionary = ITEM_CHANGES[to_version]
	var renamed := func(id: String) -> String:
		var new_id: String = (changes.renamed as Dictionary).get(id, id)
		return "" if new_id in changes.removed else new_id
	var items: Array = []
	for id: String in data[ITEMS]:
		var new_id: String = renamed.call(id)
		if new_id != "" and new_id not in items:
			items.append(new_id)
	data[ITEMS] = items
	var equipped: Dictionary = data.get("equipped", {})
	for slot: String in equipped:
		equipped[slot] = renamed.call(equipped[slot])
	var placed: Array[String] = []
	if data.has(ItemPlaces.ARMOR):
		data[ItemPlaces.ARMOR] = _keep_once(renamed.call(data[ItemPlaces.ARMOR]), placed)
	var hotbar: Array = data.get(ItemPlaces.HOTBAR, [])
	for i in hotbar.size():
		hotbar[i] = _keep_once(renamed.call(hotbar[i]), placed)
	if data.has(ItemPlaces.BAG):
		var bag := (data[ItemPlaces.BAG] as Array).map(func(id: String) -> String: return _keep_once(renamed.call(id), placed))
		data[ItemPlaces.BAG] = bag.filter(func(id: String) -> bool: return id != "")
	var hand := int(data.get("hand", 0))
	if hand >= hotbar.size() or hotbar[hand] == "":
		data["hand"] = maxi(hotbar.find_custom(func(id: String) -> bool: return id != ""), 0)


# Um item fica num lugar só: da segunda vez em diante, o lugar fica vazio.
static func _keep_once(id: String, placed: Array[String]) -> String:
	if id == "" or id in placed:
		return ""
	placed.append(id)
	return id


func _on_enemy_died(enemy: Node3D) -> void:
	var id: StringName = enemy.get(&"save_id") if &"save_id" in enemy else &""
	record(KILLED, id)


func _on_player_died() -> void:
	data["deaths"] = int(data.get("deaths", 0)) + 1
	save()


# Nate começa com a espada na mão, sem armadura (05-itens).
static func _new_game() -> Dictionary:
	return {
		"version": VERSION,
		"respawn_point": "",
		"respawn_area": "",
		"hotbar": ["sword", "", "", "", ""],
		"hand": 0,
		"bag": [],
		"armor": "",
		"equipped_elements": ["", ""],
		KILLED: [],
		OPENED: [],
		ITEMS: ["sword"],
		ELEMENTS: [],
		UPGRADES: [],
		MURALS: [],
		SANCTUARIES: [],
		"play_time": 0.0,
		"deaths": 0,
	}
