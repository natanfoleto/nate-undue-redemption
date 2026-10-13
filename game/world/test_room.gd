extends Node3D
## Sala de teste do combate (etapa 3 do 13-plano-de-producao): três lobos e, depois deles, um de cada vez, os
## inimigos da lista (o Lobo Alfa, para ver a marca de aviso do golpe forte, e o Necromante). Nate já tem o
## estilingue e a poção na barra e os elementos do Bosque, para testar as magias.

const TEST_SAVE := "user://test_room_save.json"

## Quem aparece, um de cada vez, quando a sala fica sem inimigos.
@export var next_waves: Array[PackedScene] = []
## Onde eles aparecem.
@export var next_wave_spot: Node3D

var _next := 0


# A sala de teste usa um jogo salvo próprio, sempre novo, para não mexer no jogo de verdade.
func _enter_tree() -> void:
	SaveSystem.open(TEST_SAVE)
	SaveSystem.new_game()
	GameState.store(&"slingshot")
	GameState.store(GameState.FLASK)
	GameState.learn(&"fire")
	GameState.learn(&"water")


func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(_enemy: Node3D) -> void:
	if _next >= next_waves.size():
		return
	# O inimigo que morre ainda está saindo do grupo neste quadro.
	await get_tree().process_frame
	if get_tree().get_nodes_in_group(&"enemies").is_empty() and _next < next_waves.size():
		# A posição vem antes de entrar na sala: é a casa para onde o mob volta.
		var mob := next_waves[_next].instantiate() as Node3D
		_next += 1
		mob.transform = transform.affine_inverse() * next_wave_spot.global_transform
		add_child(mob)
