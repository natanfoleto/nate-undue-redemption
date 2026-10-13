class_name Chest
extends Interactable
## Baú (08-mapa): interagir abre, e o item vai para o inventário, com o sinal de achar item (05-itens).

## Identificador do item (o nome do arquivo em game/data/items/) e o espaço dele.
@export var item_id: StringName
@export var item_slot: String
## Giro da tampa aberta, em graus, e o tempo para abrir, em segundos.
@export var open_angle := 0.0
@export var open_time := 0.0

var _open := false

@onready var _lid: Node3D = $Lid


func can_interact() -> bool:
	return not _open


func interact() -> void:
	_open = true
	_mark_done()
	create_tween().tween_property(_lid, ^"rotation_degrees:x", open_angle, open_time)
	GameState.pick_up(item_id, item_slot)
	ItemFound.show_found(self, item_id)


func _restore_done() -> void:
	_open = true
	_lid.rotation_degrees.x = open_angle
