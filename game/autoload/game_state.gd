extends Node
## Progresso da partida (12-tecnico): o ponto de retorno e o equipamento. Tudo fica no SaveSystem, que grava
## a cada conquista; ao voltar ao jogo, Nate aparece no último ponto de retorno (02-core-loop).

signal equipment_changed

## Espaços de equipamento (05-itens). Os elementos chegam com as magias.
const MELEE := "melee"
const RANGED := "ranged"
const ARMOR := "armor"

## Pasta dos itens: o identificador de um item é o nome do arquivo.
const ITEMS_FOLDER := "res://data/items/"


func respawn_point() -> StringName:
	return StringName(SaveSystem.data.get("respawn_point", ""))


func set_respawn_point(id: StringName) -> void:
	if id == respawn_point():
		return
	SaveSystem.data["respawn_point"] = String(id)
	SaveSystem.save()


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
