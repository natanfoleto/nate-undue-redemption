extends Node3D
## Sala de teste do combate (etapa 3 do 13-plano-de-producao): três lobos e, depois deles, um Lobo Alfa,
## para ver a marca de aviso do golpe forte.

const TEST_SAVE := "user://test_room_save.json"

## Quem aparece quando a sala fica sem inimigos.
@export var next_wave: PackedScene
## Onde ele aparece.
@export var next_wave_spot: Node3D

var _next_wave_sent := false


# A sala de teste usa um jogo salvo próprio, sempre novo, para não mexer no jogo de verdade.
func _enter_tree() -> void:
	SaveSystem.open(TEST_SAVE)
	SaveSystem.new_game()


func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(_enemy: Node3D) -> void:
	if _next_wave_sent or next_wave == null:
		return
	# O inimigo que morre ainda está saindo do grupo neste quadro.
	await get_tree().process_frame
	if get_tree().get_nodes_in_group(&"enemies").is_empty():
		_next_wave_sent = true
		# A posição vem antes de entrar na sala: é a casa para onde o mob volta.
		var mob := next_wave.instantiate() as Node3D
		mob.transform = transform.affine_inverse() * next_wave_spot.global_transform
		add_child(mob)
