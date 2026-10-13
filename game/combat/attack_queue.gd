class_name AttackQueue
## Fila global de ataques (06-mobs): só um número limitado de mobs prepara ataque contra Nate ao mesmo tempo;
## os outros cercam e esperam a vez.

static var _attackers: Array[Node] = []


## Pede a vez de atacar. Quem já está na fila continua com a vez.
static func try_enter(mob: Node, limit: int) -> bool:
	_attackers.assign(_attackers.filter(func(other: Variant) -> bool: return is_instance_valid(other)))
	if mob in _attackers:
		return true
	if _attackers.size() >= limit:
		return false
	_attackers.append(mob)
	return true


## Se há vez livre para mais um mob, sem pedir.
static func has_room(mob: Node, limit: int) -> bool:
	return mob in _attackers or _attackers.filter(func(other: Variant) -> bool: return is_instance_valid(other)).size() < limit


## Devolve a vez: o golpe acabou, foi interrompido ou o mob morreu.
static func leave(mob: Node) -> void:
	_attackers.erase(mob)
