class_name Strike
## Aplica um golpe a quem está na área (03-regras): cada alvo no máximo uma vez, e paredes bloqueiam.


## Procura alvos da facção dentro da área, que sai de [param origin] na direção [param forward], e entrega a cada um
## o golpe montado por [param build_hit] (recebe quem leva o golpe e devolve um Hit).
## [param already_hit] guarda quem já levou este golpe.
static func hit_area(attack: AttackData, attacker: Node3D, origin: Vector3, forward: Vector3, faction: Hurtbox.Faction,
		already_hit: Array[Node3D], build_hit: Callable) -> void:
	var space := attacker.get_world_3d().direct_space_state
	for hurtbox: Hurtbox in attacker.get_tree().get_nodes_in_group(Hurtbox.group_for(faction)):
		var receiver := hurtbox.receiver
		if receiver in already_hit:
			continue
		if not HitShape.overlaps(attack, origin, forward, hurtbox.global_position, hurtbox.radius):
			continue
		if HitShape.wall_between(space, origin, hurtbox.global_position):
			continue
		already_hit.append(receiver)
		receiver.call(&"take_hit", build_hit.call(receiver))
