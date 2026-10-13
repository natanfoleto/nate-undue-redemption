class_name ItemPickup
extends Node3D
## Item no chão (05-itens): um feixe de luz o marca de longe, e Nate o pega ao passar por ele. Também as
## melhorias (+20 de vida, +1 carga), que valem na hora e para sempre.

## Pasta das melhorias: o tipo é o nome do arquivo (heart, charge).
const UPGRADES_FOLDER := "res://data/upgrades/"

## Identificador único no mapa.
@export var save_id: StringName
## Identificador do item (o nome do arquivo em game/data/items/, ou o tipo da melhoria).
@export var item_id: StringName
## Distância em que Nate pega o item, em blocos.
@export var pickup_radius := 0.0
## É uma melhoria: o identificador no mapa começa com o tipo (ex.: heart_forest_1).
@export var upgrade := false


func _ready() -> void:
	if SaveSystem.has_record(SaveSystem.OPENED, save_id) or SaveSystem.has_record(SaveSystem.UPGRADES, save_id):
		queue_free()
		return
	($BlockModel as BlockModel).model = _item().model


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return
	var offset := player.global_position - global_position
	if Vector2(offset.x, offset.z).length() > pickup_radius:
		return
	if upgrade:
		# A melhoria guarda o próprio identificador, que começa com o tipo (05-itens).
		GameState.pick_up_upgrade(save_id)
	else:
		# O item primeiro: se o jogo cair entre as duas gravações, ele continua no chão.
		GameState.pick_up(item_id)
		SaveSystem.record(SaveSystem.OPENED, save_id)
	AudioManager.play(&"upgrade_found" if upgrade else &"item_found")
	ItemFound.show_name(self, _item().name_key)
	queue_free()


func _item() -> ItemData:
	return load((UPGRADES_FOLDER if upgrade else GameState.ITEMS_FOLDER) + item_id + ".tres")
