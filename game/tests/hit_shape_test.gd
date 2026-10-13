extends GdUnitTestSuite
## Colisão de combate no plano do chão (03-regras): as quatro formas contra o círculo de quem recebe.

const FORWARD := Vector3.FORWARD # -z
const RADIUS := 0.3


func test_circle_touches_up_to_reach_plus_target_radius() -> void:
	var attack := _attack(AttackData.Shape.CIRCLE, 3.0)
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(3.29, 0, 0), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(3.31, 0, 0), RADIUS)).is_false()


func test_sector_of_the_machete() -> void:
	# Facão: 1,5 bloco e 90°, 45° para cada lado.
	var attack := _attack(AttackData.Shape.SECTOR, 1.5, 90.0)
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, -1.4), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, _at_angle(40.0, 1.2), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, _at_angle(80.0, 1.2), RADIUS)).is_false()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, 1.0), RADIUS)).is_false()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, -1.85), RADIUS)).is_false()


func test_sector_counts_the_target_radius_at_the_edge() -> void:
	var attack := _attack(AttackData.Shape.SECTOR, 1.5, 90.0)
	# A 55° o centro está fora do setor, mas o círculo de raio 0,3 a 1 bloco ainda encosta na borda.
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, _at_angle(55.0, 1.0), RADIUS)).is_true()


func test_rectangle_in_line_ahead() -> void:
	# Salto do lobo: 3 blocos em linha, 1 bloco de largura.
	var attack := _attack(AttackData.Shape.RECTANGLE, 3.0, 0.0, 1.0)
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, -2.9), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0.75, 0, -1.5), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0.9, 0, -1.5), RADIUS)).is_false()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, -3.4), RADIUS)).is_false()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, FORWARD, Vector3(0, 0, 1.0), RADIUS)).is_false()


func test_rectangle_follows_the_direction() -> void:
	var attack := _attack(AttackData.Shape.RECTANGLE, 3.0, 0.0, 1.0)
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, Vector3.RIGHT, Vector3(2.0, 0, 0), RADIUS)).is_true()
	assert_bool(HitShape.overlaps(attack, Vector3.ZERO, Vector3.RIGHT, Vector3(0, 0, -2.0), RADIUS)).is_false()


func test_projectile_path_touches_the_target_circle() -> void:
	assert_bool(HitShape.segment_touches(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0.25, 0, -0.5), RADIUS)).is_true()
	assert_bool(HitShape.segment_touches(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0.35, 0, -0.5), RADIUS)).is_false()
	assert_bool(HitShape.segment_touches(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, -1.25), RADIUS)).is_true()


func _attack(shape: AttackData.Shape, reach: float, angle := 0.0, width := 0.0) -> AttackData:
	var attack := AttackData.new()
	attack.shape = shape
	attack.reach = reach
	attack.angle = angle
	attack.width = width
	return attack


# Ponto a [param distance] blocos, virado [param degrees] para a direita da frente (-z).
func _at_angle(degrees: float, distance: float) -> Vector3:
	var angle := deg_to_rad(degrees)
	return Vector3(sin(angle), 0, -cos(angle)) * distance
