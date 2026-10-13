class_name Arena
extends Node3D
## Arena (02-core-loop, 08-mapa): quando Nate entra, os portões fecham e as ondas vêm uma depois da outra.
## Vencida a última, os portões abrem e a arena fica vencida para sempre. Se Nate morre no meio, ela reinicia.

enum State { WAITING, FIGHTING, DONE }

## Identificador único no mapa.
@export var save_id: StringName
@export var waves: Array[ArenaWave] = []
@export var gates: Array[Gate] = []
## Onde os mobs de cada onda aparecem, um em cada ponto, em ordem.
@export var spawn_points: Array[Node3D] = []
## Retângulo do chão da arena, centrado nela, em blocos: a luta começa quando Nate entra nele.
@export var area_size := Vector2.ZERO

var state := State.WAITING
var _wave := -1
var _alive: Array[Node3D] = []


func _ready() -> void:
	if SaveSystem.has_record(SaveSystem.OPENED, save_id):
		state = State.DONE
		# Vencida antes: os portões ficam abertos ao carregar o jogo (depois de cada portão ficar pronto).
		for gate in gates:
			gate.open.call_deferred(false)
	Events.player_respawned.connect(_reset)


func _physics_process(_delta: float) -> void:
	match state:
		State.WAITING:
			if _player_inside():
				state = State.FIGHTING
				for gate in gates:
					gate.close()
				AudioManager.push_music(AudioManager.rules.arena_music)
				_next_wave()
		State.FIGHTING:
			# Sem tipo no parâmetro: um mob já liberado não pode ser passado como Node3D.
			_alive.assign(_alive.filter(func(mob: Variant) -> bool: return is_instance_valid(mob) and mob.is_in_group(&"enemies")))
			if _alive.is_empty():
				_next_wave()


func _next_wave() -> void:
	_wave += 1
	if _wave >= waves.size():
		state = State.DONE
		SaveSystem.record(SaveSystem.OPENED, save_id)
		for gate in gates:
			gate.open()
		AudioManager.pop_music()
		return
	if waves[_wave] == null or spawn_points.is_empty():
		push_warning("Arena %s: onda %d vazia ou sem pontos de surgir." % [save_id, _wave + 1])
		return
	var scenes := waves[_wave].mobs
	for i in scenes.size():
		if scenes[i] == null:
			continue
		var mob := scenes[i].instantiate() as Node3D
		var spot := spawn_points[i % spawn_points.size()]
		mob.transform = global_transform.affine_inverse() * spot.global_transform
		add_child(mob)
		_alive.append(mob)


# Arena incompleta reinicia quando Nate morre (02-core-loop).
func _reset() -> void:
	if state != State.FIGHTING:
		return
	for mob in _alive:
		if is_instance_valid(mob):
			mob.queue_free()
	_alive.clear()
	_wave = -1
	state = State.WAITING
	AudioManager.pop_music()
	for gate in gates:
		gate.open()


func _player_inside() -> bool:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return false
	var offset := player.global_position - global_position
	return absf(offset.x) <= area_size.x / 2.0 and absf(offset.z) <= area_size.y / 2.0
