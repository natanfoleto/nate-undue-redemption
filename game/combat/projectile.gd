class_name Projectile
extends Node3D
## Projétil (03-regras): voa reto, para na primeira parede ou no primeiro alvo e some no fim do alcance.

var _attack: AttackData
var _direction := Vector3.ZERO
var _faction := Hurtbox.Faction.ENEMY
var _build_hit: Callable
var _on_stop: Callable
var _traveled := 0.0
var _pierced: Array[Node3D] = []

## Atravessa os inimigos (a flecha do Arco marajoara): acerta cada um uma vez e segue.
var pierce := false


## Dispara na direção dada. [param build_hit] recebe quem foi acertado e devolve o Hit; vazio, o projétil não
## fere quem acerta (a Bola de Fogo fere só pela explosão). [param on_stop] recebe o ponto onde ele parou.
func launch(attack: AttackData, direction: Vector3, faction: Hurtbox.Faction, build_hit: Callable, on_stop := Callable()) -> void:
	_attack = attack
	_direction = Vector3(direction.x, 0.0, direction.z).normalized()
	_faction = faction
	_build_hit = build_hit
	_on_stop = on_stop
	rotation.y = atan2(-_direction.x, -_direction.z)


func _physics_process(delta: float) -> void:
	var step := minf(_attack.projectile_speed * delta, _attack.reach - _traveled)
	var from := global_position
	var to := from + _direction * step
	var wall := get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(from, to, HitShape.WORLD_LAYER))
	if not wall.is_empty():
		to = wall.position
	if pierce:
		for hurtbox in _targets(from, to):
			if hurtbox.receiver not in _pierced:
				_pierced.append(hurtbox.receiver)
				hurtbox.receiver.call(&"take_hit", _build_hit.call(hurtbox.receiver))
	else:
		var targets := _targets(from, to)
		if not targets.is_empty():
			var target: Hurtbox = targets[0]
			if _build_hit.is_valid():
				target.receiver.call(&"take_hit", _build_hit.call(target.receiver))
			_stop(target.global_position)
			return
	# Alvos do cenário, como alavancas distantes, também levam o tiro (04-player).
	if not wall.is_empty() and wall.collider.has_method(&"take_shot"):
		wall.collider.call(&"take_shot")
	global_position = to
	_traveled += step
	if not wall.is_empty() or _traveled >= _attack.reach:
		_stop(to)


func _stop(where: Vector3) -> void:
	if _on_stop.is_valid():
		_on_stop.call(where)
	queue_free()


# Os alvos tocados no trecho voado neste quadro, do mais perto do começo para o mais longe.
func _targets(from: Vector3, to: Vector3) -> Array[Hurtbox]:
	var found: Array[Hurtbox] = []
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(_faction)):
		if HitShape.segment_touches(from, to, hurtbox.global_position, hurtbox.radius):
			found.append(hurtbox)
	var start := Vector2(from.x, from.z)
	found.sort_custom(func(a: Hurtbox, b: Hurtbox) -> bool:
		return start.distance_to(Vector2(a.global_position.x, a.global_position.z)) < start.distance_to(Vector2(b.global_position.x, b.global_position.z)))
	return found
