class_name AreaMesh
## Malhas planas das áreas de golpe, no chão, com a frente para -z, para a marca de aviso e o rastro.
## O UV.x vai de 0 em quem golpeia até 1 na borda de fora: é por ele que as listras enchem.

## Segmentos de uma volta inteira: deixa o círculo redondo.
const SEGMENTS_PER_TURN := 48


## A área inteira do golpe.
static func build(attack: AttackData) -> ArrayMesh:
	match attack.shape:
		AttackData.Shape.CIRCLE:
			return _fan(attack.reach, TAU)
		AttackData.Shape.SECTOR:
			return _fan(attack.reach, deg_to_rad(attack.angle))
		_:
			return _rectangle(attack.reach, attack.width)


## Faixa curva na borda do setor, entre [param inner] e [param outer] do alcance: o rastro do golpe.
static func arc(radius_inner: float, radius_outer: float, angle_degrees: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var angle := deg_to_rad(angle_degrees)
	var steps := maxi(ceili(SEGMENTS_PER_TURN * angle / TAU), 1)
	for i in steps:
		var a0 := -angle / 2.0 + angle * i / steps
		var a1 := -angle / 2.0 + angle * (i + 1) / steps
		var in0 := _point(a0, radius_inner)
		var in1 := _point(a1, radius_inner)
		var out0 := _point(a0, radius_outer)
		var out1 := _point(a1, radius_outer)
		_triangle(surface, [in0, out0, out1], [0.0, 1.0, 1.0])
		_triangle(surface, [in0, out1, in1], [0.0, 1.0, 0.0])
	return surface.commit()


static func _fan(radius: float, angle: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := maxi(ceili(SEGMENTS_PER_TURN * angle / TAU), 1)
	for i in steps:
		var a0 := -angle / 2.0 + angle * i / steps
		var a1 := -angle / 2.0 + angle * (i + 1) / steps
		_triangle(surface, [Vector3.ZERO, _point(a0, radius), _point(a1, radius)], [0.0, 1.0, 1.0])
	return surface.commit()


static func _rectangle(length: float, width: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var near_left := Vector3(-width / 2.0, 0.0, 0.0)
	var near_right := Vector3(width / 2.0, 0.0, 0.0)
	var far_left := Vector3(-width / 2.0, 0.0, -length)
	var far_right := Vector3(width / 2.0, 0.0, -length)
	_triangle(surface, [near_left, far_left, far_right], [0.0, 1.0, 1.0])
	_triangle(surface, [near_left, far_right, near_right], [0.0, 1.0, 0.0])
	return surface.commit()


# Ponto no chão a [param angle] radianos da frente (-z), virando para a direita (+x) com ângulo positivo.
static func _point(angle: float, radius: float) -> Vector3:
	return Vector3(sin(angle), 0.0, -cos(angle)) * radius


static func _triangle(surface: SurfaceTool, points: Array, fill: Array) -> void:
	for i in 3:
		surface.set_normal(Vector3.UP)
		surface.set_uv(Vector2(fill[i], 0.0))
		surface.add_vertex(points[i])
