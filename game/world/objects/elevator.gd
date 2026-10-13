class_name Elevator
extends Interactable
## Elevador velho da mina (08-mapa): com Nate em cima, interagir faz descer para Agartha. Na descida ele
## quebra e deixa Nate no Bosque de Fungos; até o Bosque existir, a descida termina a primeira parte do jogo.

signal descended

## Quanto desce, em blocos, e em quanto tempo, em segundos.
@export var depth := 0.0
@export var descent_time := 0.0

var _used := false

@onready var _platform: Node3D = $Platform


func can_interact() -> bool:
	return not _used


func interact() -> void:
	_used = true
	var player := get_tree().get_first_node_in_group(&"player") as Player
	player.set_cinematic(true)
	var tween := create_tween().set_parallel()
	tween.tween_property(_platform, ^"position:y", _platform.position.y - depth, descent_time)
	tween.tween_property(player, ^"global_position:y", player.global_position.y - depth, descent_time)
	tween.chain().tween_callback(descended.emit)
