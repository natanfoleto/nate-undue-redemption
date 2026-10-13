class_name AreaLevel
extends Node3D
## Uma área do mapa (12-tecnico): uma cena por área. Ao abrir, põe Nate no ponto de chegada (vindo de outra
## área) ou no último ponto de retorno (02-core-loop); num jogo novo, no começo da área.

## Ponto de retorno de um jogo novo.
@export var start_point: RespawnPoint
@export var player: Player
## Saída para a próxima área; até ela existir, chegar nela termina a parte jogável.
@export var exit: AreaExit
@export var end_screen: EndScreen
## A música da área e o som de fundo (10-arte-audio); vazios, nada toca.
@export var music: AudioStream
@export var ambience: AudioStream


func _ready() -> void:
	var point := start_point
	var wanted := GameState.arrival if GameState.arrival != &"" else GameState.respawn_point()
	for candidate: RespawnPoint in get_tree().get_nodes_in_group(&"respawn_points"):
		if candidate.id == wanted:
			point = candidate
	GameState.arrival = &""
	if GameState.respawn_point() == &"":
		GameState.set_respawn_point(start_point.id)
	player.global_position = point.global_position
	# Volta para o ponto de retorno desta área; se ele fica em outra área, a morte troca de área.
	var spawn := point
	for candidate: RespawnPoint in get_tree().get_nodes_in_group(&"respawn_points"):
		if candidate.id == GameState.respawn_point():
			spawn = candidate
	player.set_spawn(spawn.global_position, spawn.facing())
	player.facing = point.facing()
	if exit:
		exit.reached.connect(end_screen.show_end)
	AudioManager.play_music(music)
	AudioManager.play_ambience(ambience)
	GameState.fade_in()
