extends Node
## Progresso da partida (12-tecnico): o ponto de retorno, os itens, os elementos, as melhorias e a troca de área.
## Tudo fica no SaveSystem, que grava a cada conquista; ao voltar ao jogo, Nate aparece no último ponto de retorno
## (02-core-loop).

## Um item mudou de lugar (a barra, a mochila ou a armadura).
signal inventory_changed
## Nate pegou outro espaço da barra na mão.
signal hand_changed
signal elements_changed
signal upgrades_changed

## Lugares dos itens (ItemPlaces): a barra fixa, com os itens de mão (armas e a poção), o espaço escolhido sendo o
## que Nate segura; a mochila, com o resto; e a armadura vestida.
const HOTBAR := ItemPlaces.HOTBAR
const BAG := ItemPlaces.BAG
const ARMOR := ItemPlaces.ARMOR
const HOTBAR_SIZE := ItemPlaces.HOTBAR_SIZE
const BAG_SIZE := ItemPlaces.BAG_SIZE

## Pasta dos itens: o identificador de um item é o nome do arquivo.
const ITEMS_FOLDER := ItemPlaces.ITEMS_FOLDER
## Pasta dos elementos, do mesmo jeito.
const ELEMENTS_FOLDER := "res://data/elements/"
## Pasta dos santuários: o identificador é o nome do arquivo.
const SANCTUARIES_FOLDER := "res://data/sanctuaries/"
## A poção de vida, guardada na lista de itens quando Nate a ganha.
const FLASK := &"flask"
## O Selo, do mesmo jeito.
const SEAL := &"seal"
## Tipos de melhoria: o identificador de cada uma começa com o tipo (ex.: "heart_forest_1").
const HEART_UPGRADE := "heart"
const CHARGE_UPGRADE := "charge"

## Ponto onde Nate chega na próxima área (o elevador); vazio, ele aparece no ponto de retorno.
var arrival: StringName

var _fade: ColorRect


func _ready() -> void:
	# A tela escurece mesmo com o jogo pausado (o menu do santuário).
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Tela preta da troca de área, por cima de tudo.
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)


func _process(delta: float) -> void:
	# Tempo de jogo, para o resumo do fim: só conta numa área, com o jogo andando.
	if get_tree().paused or not get_tree().current_scene is AreaLevel:
		return
	SaveSystem.data["play_time"] = float(SaveSystem.data.get("play_time", 0.0)) + delta


func respawn_point() -> StringName:
	return StringName(SaveSystem.data.get("respawn_point", ""))


## A área do ponto de retorno, para onde Nate volta ao morrer e ao abrir o jogo.
func respawn_area() -> String:
	return SaveSystem.data.get("respawn_area", "")


## Muda o ponto de retorno; sem [param area], ele fica na área aberta agora.
func set_respawn_point(id: StringName, area := "") -> void:
	if area == "":
		area = _current_area()
	if id == respawn_point() and area == respawn_area():
		return
	SaveSystem.data["respawn_point"] = String(id)
	SaveSystem.data["respawn_area"] = area
	SaveSystem.save()


## Troca de área (12-tecnico): a tela escurece, a cena carrega e Nate aparece no ponto de chegada. A nova área
## clareia a tela quando fica pronta.
func change_area(scene_path: String, arrival_id: StringName) -> void:
	arrival = arrival_id
	await fade_out()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)


## Escurece a tela.
func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, ^"color:a", 1.0, Balance.world.area_fade_time)
	await tween.finished


## Clareia a tela (a área nova ficou pronta).
func fade_in() -> void:
	if _fade.color.a == 0.0:
		return
	create_tween().tween_property(_fade, ^"color:a", 0.0, Balance.world.area_fade_time)


## Depois do primeiro santuário, a morte sempre leva de volta ao último santuário (02-core-loop).
func has_sanctuary() -> bool:
	return not (SaveSystem.data.get(SaveSystem.SANCTUARIES, []) as Array).is_empty()


## Santuários já visitados, em ordem, para a viagem rápida.
func visited_sanctuaries() -> Array[SanctuaryData]:
	var list: Array[SanctuaryData] = []
	for id: String in SaveSystem.data.get(SaveSystem.SANCTUARIES, []):
		list.append(load(SANCTUARIES_FOLDER + id + ".tres"))
	return list


func has_flask() -> bool:
	return SaveSystem.has_record(SaveSystem.ITEMS, FLASK)


## Quantas melhorias de um tipo Nate já achou.
func upgrade_count(kind: String) -> int:
	return (SaveSystem.data.get(SaveSystem.UPGRADES, []) as Array).filter(
		func(id: String) -> bool: return id.begins_with(kind + "_")).size()


## Pega uma melhoria: vale na hora e para sempre (05-itens).
func pick_up_upgrade(upgrade_id: StringName) -> void:
	SaveSystem.record(SaveSystem.UPGRADES, upgrade_id)
	upgrades_changed.emit()
	Events.item_picked.emit(upgrade_id)


## Cargas do frasco: as de Nate mais as melhorias (05-itens).
func flask_charges() -> int:
	return Balance.player.flask_charges + upgrade_count(CHARGE_UPGRADE)


## O item num lugar: um espaço da barra ou da mochila, ou a armadura (sem índice). Nulo se o lugar está vazio.
func item_at(place: String, index := 0) -> ItemData:
	return ItemPlaces.load_item(ItemPlaces.id_at(SaveSystem.data, place, index))


## O espaço da barra que Nate segura.
func hand() -> int:
	return clampi(int(SaveSystem.data.get("hand", 0)), 0, HOTBAR_SIZE - 1)


## O item na mão de Nate, ou nulo (mão vazia).
func hand_item() -> ItemData:
	return item_at(HOTBAR, hand())


## Pega outro espaço da barra na mão (os números, a roda do mouse); passa do último para o primeiro.
func select_hand(index: int) -> void:
	index = posmod(index, HOTBAR_SIZE)
	if index == hand():
		return
	# Sem gravar: a escolha vai junto na próxima gravação.
	SaveSystem.data["hand"] = index
	hand_changed.emit()


func worn_armor() -> ArmorData:
	return item_at(ARMOR) as ArmorData


## Se dá para trocar o conteúdo de dois lugares (o inventário).
func can_move(from: String, from_index: int, to: String, to_index: int) -> bool:
	return ItemPlaces.can_move(SaveSystem.data, from, from_index, to, to_index)


## Troca o conteúdo de dois lugares (o inventário).
func move(from: String, from_index: int, to: String, to_index: int) -> void:
	if ItemPlaces.move(SaveSystem.data, from, from_index, to, to_index):
		SaveSystem.save()
		inventory_changed.emit()


## Pega um item: Nate guarda tudo o que acha (05-itens). Uma arma nova já vai para a mão.
func pick_up(item_id: StringName) -> void:
	store(item_id)
	var spot := ItemPlaces.list(SaveSystem.data, HOTBAR).find(String(item_id))
	if spot >= 0 and not ItemPlaces.load_item(item_id) is PotionData:
		select_hand(spot)
	Events.item_picked.emit(item_id)


## Guarda um item sem o aviso de item achado (a poção do primeiro santuário avisa depois da luz).
func store(item_id: StringName) -> void:
	SaveSystem.record(SaveSystem.ITEMS, item_id)
	if ItemPlaces.place(SaveSystem.data, item_id):
		SaveSystem.save()
	inventory_changed.emit()


## Elementos aprendidos, em ordem.
func learned_elements() -> Array:
	return SaveSystem.data.get(SaveSystem.ELEMENTS, [])


## Se Nate já aprendeu o elemento (a Terra quebra as paredes rachadas).
func has_learned(element_id: StringName) -> bool:
	return SaveSystem.has_record(SaveSystem.ELEMENTS, element_id)


## O Selo, a lasca do muiraquitã, achado no fim das Ruínas (05-itens).
func has_seal() -> bool:
	return SaveSystem.has_record(SaveSystem.ITEMS, SEAL)


## O muiraquitã acorda no primeiro pergaminho e dá a Luz Ancestral (05-itens).
func has_light() -> bool:
	return not learned_elements().is_empty()


## Aprende um elemento (o pergaminho): guarda e, se houver espaço vazio, já equipa.
func learn(element_id: StringName) -> void:
	SaveSystem.record(SaveSystem.ELEMENTS, element_id)
	var slots := _element_slots()
	var empty := slots.find("")
	if empty >= 0 and String(element_id) not in slots:
		slots[empty] = String(element_id)
		SaveSystem.save()
	elements_changed.emit()
	Events.item_picked.emit(element_id)


## O elemento equipado num dos 2 espaços (0 ou 1), ou nulo.
func equipped_element(slot: int) -> ElementData:
	var id: String = _element_slots()[slot]
	return load(ELEMENTS_FOLDER + id + ".tres") if id != "" else null


func equipped_element_id(slot: int) -> StringName:
	return StringName(_element_slots()[slot])


func has_element_equipped(element_id: StringName) -> bool:
	return String(element_id) in _element_slots()


## Troca o elemento de um espaço (o inventário).
func equip_element(slot: int, element_id: StringName) -> void:
	var slots := _element_slots()
	var other := 1 - slot
	if slots[other] == String(element_id):
		slots[other] = slots[slot]
	slots[slot] = String(element_id)
	SaveSystem.save()
	elements_changed.emit()


## Tira o elemento de um espaço (o inventário).
func unequip_element(slot: int) -> void:
	_element_slots()[slot] = ""
	SaveSystem.save()
	elements_changed.emit()


## O identificador de um item: o nome do arquivo.
static func item_id(item: Resource) -> StringName:
	return StringName(item.resource_path.get_file().get_basename())


func _element_slots() -> Array:
	return SaveSystem.data.get_or_add("equipped_elements", ["", ""])


func _current_area() -> String:
	var scene := get_tree().current_scene
	return scene.scene_file_path if scene else ""
