extends Node
## Progresso da partida (12-tecnico): o ponto de retorno, o equipamento, os elementos, as melhorias e a troca
## de área. Tudo fica no SaveSystem, que grava a cada conquista; ao voltar ao jogo, Nate aparece no último
## ponto de retorno (02-core-loop).

signal equipment_changed
signal elements_changed
signal upgrades_changed

## Espaços de equipamento (05-itens). Os elementos chegam com as magias.
const MELEE := "melee"
const RANGED := "ranged"
const ARMOR := "armor"

## Pasta dos itens: o identificador de um item é o nome do arquivo.
const ITEMS_FOLDER := "res://data/items/"
## Pasta dos elementos, do mesmo jeito.
const ELEMENTS_FOLDER := "res://data/elements/"
## Pasta dos santuários: o identificador é o nome do arquivo.
const SANCTUARIES_FOLDER := "res://data/sanctuaries/"
## O frasco, guardado na lista de itens quando Nate o ganha.
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


## O item equipado num espaço, ou nulo.
func equipped(slot: String) -> Resource:
	var id: String = (SaveSystem.data.get("equipped", {}) as Dictionary).get(slot, "")
	return load(ITEMS_FOLDER + id + ".tres") if id != "" else null


func equip(slot: String, item_id: StringName) -> void:
	(SaveSystem.data["equipped"] as Dictionary)[slot] = String(item_id)
	SaveSystem.save()
	equipment_changed.emit()


## Pega um item: Nate guarda tudo o que acha (05-itens). Enquanto não há inventário, o item já entra
## no espaço dele se o espaço estiver vazio.
func pick_up(item_id: StringName, slot: String) -> void:
	SaveSystem.record(SaveSystem.ITEMS, item_id)
	if equipped(slot) == null:
		equip(slot, item_id)
	Events.item_picked.emit(item_id)


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


## Itens guardados de um espaço, em ordem de achado (o inventário).
func owned(slot: String) -> Array[Resource]:
	var list: Array[Resource] = []
	for id: String in SaveSystem.data.get(SaveSystem.ITEMS, []):
		var path := ITEMS_FOLDER + id + ".tres"
		if not ResourceLoader.exists(path):
			continue
		var item: Resource = load(path)
		if _slot_of(item) == slot:
			list.append(item)
	return list


## O identificador de um item: o nome do arquivo.
static func item_id(item: Resource) -> StringName:
	return StringName(item.resource_path.get_file().get_basename())


func _element_slots() -> Array:
	return SaveSystem.data.get_or_add("equipped_elements", ["", ""])


static func _slot_of(item: Resource) -> String:
	if item is MeleeWeaponData:
		return MELEE
	if item is RangedWeaponData:
		return RANGED
	if item is ArmorData:
		return ARMOR
	return ""


func _current_area() -> String:
	var scene := get_tree().current_scene
	return scene.scene_file_path if scene else ""
