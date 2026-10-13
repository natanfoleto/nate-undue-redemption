class_name AreaLevel
extends Node3D
## Uma área do mapa (12-tecnico): uma cena por área. Ao abrir, põe Nate no último ponto de retorno
## (02-core-loop); num jogo novo, no começo da área.

## Ponto de retorno de um jogo novo.
@export var start_point: RespawnPoint
@export var player: Player
## Elevador que leva à próxima área; até ela existir, a descida termina a parte jogável.
@export var exit_elevator: Elevator
@export var end_screen: EndScreen


func _ready() -> void:
	var point := start_point
	for candidate: RespawnPoint in get_tree().get_nodes_in_group(&"respawn_points"):
		if candidate.id == GameState.respawn_point():
			point = candidate
	if GameState.respawn_point() == &"":
		GameState.set_respawn_point(start_point.id)
	var facing := Vector3.FORWARD.rotated(Vector3.UP, point.global_rotation.y)
	player.global_position = point.global_position
	player.set_spawn(point.global_position, facing)
	if exit_elevator:
		exit_elevator.descended.connect(end_screen.show_end)
