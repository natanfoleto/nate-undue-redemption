class_name Chest
extends Interactable
## Baú (08-mapa): interagir abre, e o item vai para o inventário, com o sinal de achar item (05-itens). Um baú pode
## guardar uma melhoria no lugar do item: o identificador no mapa dele começa com o tipo dela (ex.: charge_ruins_2).

## Identificador do item (o nome do arquivo em game/data/items/), ou o tipo da melhoria.
@export var item_id: StringName
## Guarda uma melhoria (+20 de vida, +1 carga), que vale na hora e para sempre.
@export var upgrade := false
## Giro da tampa aberta, em graus, e o tempo para abrir, em segundos.
@export var open_angle := 0.0
@export var open_time := 0.0

var _open := false

@onready var _lid: Node3D = $Lid


func can_interact() -> bool:
	return not _open


func interact() -> void:
	_open = true
	# O item primeiro: se o jogo cair entre as duas gravações, o baú ainda abre de novo.
	if upgrade:
		GameState.pick_up_upgrade(save_id)
	else:
		GameState.pick_up(item_id)
	_mark_done()
	create_tween().tween_property(_lid, ^"rotation_degrees:x", open_angle, open_time)
	AudioManager.play(&"chest_open", global_position)
	AudioManager.play(&"upgrade_found" if upgrade else &"item_found")
	if upgrade:
		ItemFound.show_name(self, (load(ItemPickup.UPGRADES_FOLDER + item_id + ".tres") as ItemData).name_key)
	else:
		ItemFound.show_found(self, item_id)


func _restore_done() -> void:
	_open = true
	_lid.rotation_degrees.x = open_angle
