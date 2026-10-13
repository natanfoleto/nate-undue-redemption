class_name Interactable
extends StaticBody3D
## Objeto do cenário com que Nate interage de perto, apertando interagir (08-mapa).
## O estado de cada objeto (aberto, puxado) é salvo na hora pelo identificador único no mapa.

## Identificador único no mapa.
@export var save_id: StringName
## Distância de Nate até o objeto em que dá para interagir, em blocos.
@export var reach := 0.0


func _ready() -> void:
	add_to_group(&"interactables")
	if save_id != &"" and SaveSystem.has_record(SaveSystem.OPENED, save_id):
		_restore_done()


## Se Nate pode interagir agora (ex.: o baú ainda fechado).
func can_interact() -> bool:
	return true


func interact() -> void:
	pass


## Guarda que o objeto já foi usado.
func _mark_done() -> void:
	SaveSystem.record(SaveSystem.OPENED, save_id)


## Põe o objeto no estado de já usado, ao carregar o jogo salvo.
func _restore_done() -> void:
	pass
