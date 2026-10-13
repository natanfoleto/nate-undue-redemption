class_name HitShape
## Colisão de combate no plano do chão (03-regras): a área do golpe contra o círculo de quem recebe.
## A área sai de quem golpeia ([param origin]) na direção do golpe ([param forward]). Tudo em blocos.

## Camada de física das paredes e do chão.
const WORLD_LAYER := 1
## Altura em que se olha se há parede entre dois pontos, em blocos: a do peito de Nate.
const WALL_CHECK_HEIGHT := 1.0


## Se a área do golpe toca o círculo do alvo.
static func overlaps(attack: AttackData, origin: Vector3, forward: Vector3, target: Vector3, target_radius: float) -> bool:
	var to_target := Vector2(target.x - origin.x, target.z - origin.z)
	var direction := Vector2(forward.x, forward.z).normalized()
	match attack.shape:
		AttackData.Shape.CIRCLE:
			return to_target.length() <= attack.reach + target_radius
		AttackData.Shape.SECTOR:
			var distance := to_target.length()
			if distance > attack.reach + target_radius:
				return false
			if distance <= target_radius:
				return true
			# O círculo do alvo alarga o ângulo em que ele ainda encosta no setor.
			var half_angle := deg_to_rad(attack.angle / 2.0) + asin(target_radius / distance)
			return absf(direction.angle_to(to_target)) <= half_angle
		AttackData.Shape.RECTANGLE:
			var local := Vector2(to_target.dot(direction), to_target.dot(Vector2(-direction.y, direction.x)))
			var closest := Vector2(clampf(local.x, 0.0, attack.reach), clampf(local.y, -attack.width / 2.0, attack.width / 2.0))
			return local.distance_to(closest) <= target_radius
		_:
			return false


## Se um segmento no chão (o voo de um projétil) toca o círculo do alvo.
static func segment_touches(from: Vector3, to: Vector3, target: Vector3, radius: float) -> bool:
	var closest := Geometry3D.get_closest_point_to_segment(Vector3(target.x, 0.0, target.z),
		Vector3(from.x, 0.0, from.z), Vector3(to.x, 0.0, to.z))
	return closest.distance_to(Vector3(target.x, 0.0, target.z)) <= radius


## Se há parede entre dois pontos do chão: paredes bloqueiam golpes e projéteis (03-regras).
static func wall_between(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3) -> bool:
	var lift := Vector3.UP * WALL_CHECK_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from + lift, to + lift, WORLD_LAYER)
	return not space.intersect_ray(query).is_empty()
