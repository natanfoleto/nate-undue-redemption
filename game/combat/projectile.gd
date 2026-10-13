class_name Projectile
extends Node3D
## Projétil (03-regras): voa reto, para na primeira parede ou no primeiro alvo e some no fim do alcance.

var _attack: AttackData
var _direction := Vector3.ZERO
var _faction := Hurtbox.Faction.ENEMY
var _build_hit: Callable
var _traveled := 0.0


## Dispara na direção dada. [param build_hit] recebe quem foi acertado e devolve o Hit.
func launch(attack: AttackData, direction: Vector3, faction: Hurtbox.Faction, build_hit: Callable) -> void:
	_attack = attack
	_direction = Vector3(direction.x, 0.0, direction.z).normalized()
	_faction = faction
	_build_hit = build_hit
	rotation.y = atan2(-_direction.x, -_direction.z)


func _physics_process(delta: float) -> void:
	var step := minf(_attack.projectile_speed * delta, _attack.reach - _traveled)
	var from := global_position
	var to := from + _direction * step
	var wall := get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(from, to, HitShape.WORLD_LAYER))
	if not wall.is_empty():
		to = wall.position
	var target := _first_target(from, to)
	if target:
		target.receiver.call(&"take_hit", _build_hit.call(target.receiver))
		queue_free()
		return
	# Alvos do cenário, como alavancas distantes, também levam o tiro (04-player).
	if not wall.is_empty() and wall.collider.has_method(&"take_shot"):
		wall.collider.call(&"take_shot")
	global_position = to
	_traveled += step
	if not wall.is_empty() or _traveled >= _attack.reach:
		queue_free()


# O alvo mais perto do começo do trecho voado neste quadro.
func _first_target(from: Vector3, to: Vector3) -> Hurtbox:
	var best: Hurtbox = null
	var best_distance := INF
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(_faction)):
		if not HitShape.segment_touches(from, to, hurtbox.global_position, hurtbox.radius):
			continue
		var distance := Vector2(from.x, from.z).distance_to(Vector2(hurtbox.global_position.x, hurtbox.global_position.z))
		if distance < best_distance:
			best = hurtbox
			best_distance = distance
	return best
