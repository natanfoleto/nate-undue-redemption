extends RefCounted
# Montador do terreno das áreas (usado por make_mine, make_forest e make_ruins). Lê dois rascunhos em texto, com um
# caractere por bloco (x para a direita, z para baixo, o norte em cima):
# - o do mapa diz o que é chão (com os objetos em cima), abismo ou o resto (parede, rocha, vazio);
# - o das alturas diz a altura do chão: um dígito é a altura; n, s, e e w são escadas que sobem para aquele lado, a
#   partir da altura do bloco de baixo; de A a J, ponte na altura 0 a 9.
#
# Em volta do chão, o terreno preenche tudo até a margem, para a câmera nunca ver o vazio: rente ao chão, a parede
# (baixa na frente da câmera, alta e irregular atrás); depois, morros subindo atrás e abismos descendo na frente, com
# o fundo de cada área (água, fungos, lava). Nada pode tampar a visão de Nate: a altura de cada coluna tem um teto,
# o da linha de visão da câmera até o chão atrás dela.

const STAIRS := "nsew"
const STAIR_DIRECTIONS := {"n": Vector2i(0, -1), "s": Vector2i(0, 1), "e": Vector2i(1, 0), "w": Vector2i(-1, 0)}
const BRIDGES := "ABCDEFGHIJ"
const SIDES: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
# Para onde a câmera olha (de onde ela vem): do sudeste.
const TOWARD_CAMERA := Vector2(0.70710678, 0.70710678)

enum Kind { FLOOR, BRIDGE, CHASM, WALL, FILL }

var rows: PackedStringArray
var height_rows: PackedStringArray
# Caracteres do rascunho que são chão (onde se anda ou onde fica um objeto em cima do chão) e que são abismo.
var floor_chars := ""
var chasm_chars := "~"
# Quantos blocos o terreno se estende além do chão, em cada direção.
var margin := 24
# Altura das paredes acima do chão vizinho: na frente da câmera (sul e leste do chão), atrás, e quanto as de trás
# variam.
var front_height := 1
var back_height := 3
var back_variation := 2
# Até que altura acima do chão uma parede baixa segura tiros e a visão dos mobs, com blocos invisíveis.
var sight_height := 3
# Profundidade dos abismos, de dentro da área e da frente da câmera, abaixo do chão vizinho.
var chasm_depth := 7
# Morros atrás: quanto sobem por bloco de distância e até que altura acima do chão.
var rise := 0.6
var peak := 10
# Chance de uma pedra subir do fundo dos abismos da frente, e até onde ela sobe abaixo do chão.
var island_chance := 0.06
var island_top := 2
# Folga do teto da visão: a altura que precisa ficar à vista acima do chão (o peito de Nate).
var view_height := 1.0
# Até quantos blocos na diagonal à frente de um chão o terreno vira abismo, em vez de morro: entre uma sala e outra,
# fica o fundo; morro alto, só na borda de fora.
var front_reach := 10

var low := Vector2i.ZERO
var high := Vector2i.ZERO

var _heights := {}
var _kinds := {}
var _tops := {}
var _distance := {}
var _source := {}
var _wall_heights := {}
var _caps := {}
var _behind := {}


func setup(layout_rows: PackedStringArray, layout_heights: PackedStringArray) -> void:
	rows = layout_rows
	height_rows = layout_heights
	var width := 0
	for row in rows:
		width = maxi(width, row.length())
	low = Vector2i(-margin, -margin)
	high = Vector2i(width + margin, rows.size() + margin)
	for z in rows.size():
		for x in rows[z].length():
			var kind := _read_kind(x, z)
			if kind != Kind.FILL:
				_kinds[Vector2i(x, z)] = kind
				_heights[Vector2i(x, z)] = _read_height(x, z)
	_measure_distances()
	_measure_caps()
	for z in range(low.y, high.y):
		for x in range(low.x, high.x):
			var cell := Vector2i(x, z)
			if not _kinds.has(cell):
				# Parede só rente ao chão; em volta dos abismos, o resto do terreno (morro atrás, abismo na frente).
				_kinds[cell] = Kind.WALL if _touches_walkable(x, z) else Kind.FILL
			_tops[cell] = _desired_top(x, z)


func cell(x: int, z: int) -> String:
	if z < 0 or z >= rows.size() or x < 0 or x >= rows[z].length():
		return " "
	return rows[z][x]


func kind(x: int, z: int) -> Kind:
	return _kinds.get(Vector2i(x, z), Kind.FILL)


func is_floor(x: int, z: int) -> bool:
	return kind(x, z) == Kind.FLOOR


func is_bridge(x: int, z: int) -> bool:
	return kind(x, z) == Kind.BRIDGE


func is_chasm(x: int, z: int) -> bool:
	return kind(x, z) == Kind.CHASM


## Onde se anda: chão e ponte.
func is_walkable(x: int, z: int) -> bool:
	var here := kind(x, z)
	return here == Kind.FLOOR or here == Kind.BRIDGE


## Altura do chão de um bloco jogável (a de baixo, nas escadas; a da beira, nos abismos).
func height(x: int, z: int) -> int:
	return _heights.get(Vector2i(x, z), 0)


## Altura do chão em que um objeto fica: a do bloco, se for jogável; senão, a do chão vizinho mais alto.
func ground(x: int, z: int) -> int:
	return height(x, z) if _heights.has(Vector2i(x, z)) else _neighbor_height(x, z)


## O topo de uma coluna: o y de cima do bloco mais alto dela.
func top(x: int, z: int) -> int:
	return _tops.get(Vector2i(x, z), 0)


## Troca o topo de uma coluna (o paredão, a clareira de fora), sempre abaixo do teto da visão.
func set_top(x: int, z: int, value: int) -> void:
	_tops[Vector2i(x, z)] = mini(value, cap(x, z))


## Troca o topo de uma coluna sem olhar o teto da visão (o poste do lampião, as árvores da borda).
func force_top(x: int, z: int, value: int) -> void:
	_tops[Vector2i(x, z)] = value


## Distância até o bloco jogável mais perto, contando em quadrados (fora da margem, 999).
func distance(x: int, z: int) -> int:
	return _distance.get(Vector2i(x, z), 999)


## O bloco jogável mais perto.
func source(x: int, z: int) -> Vector2i:
	return _source.get(Vector2i(x, z), Vector2i(x, z))


## Altura do chão mais perto.
func base(x: int, z: int) -> int:
	return height(source(x, z).x, source(x, z).y)


## De que lado do chão mais perto o bloco fica: −1 atrás (noroeste, longe da câmera), 1 na frente (sudeste).
func side(x: int, z: int) -> float:
	var away := Vector2(Vector2i(x, z) - source(x, z))
	return away.normalized().dot(TOWARD_CAMERA) if not away.is_zero_approx() else 0.0


## O teto da visão: a coluna mais alta que ainda deixa ver o chão atrás dela.
func cap(x: int, z: int) -> int:
	return _caps.get(Vector2i(x, z), 999)


## Fundo dos abismos perto do bloco: a água, os fungos ou a lava ficam nessa altura (o topo do fundo).
func bottom_level(x: int, z: int) -> int:
	return base(x, z) - chasm_depth + 1


## No fundo de um abismo: o topo da coluna é o do fundo.
func is_bottom(x: int, z: int) -> bool:
	var here := kind(x, z)
	return (here == Kind.CHASM or here == Kind.FILL) and top(x, z) <= bottom_level(x, z)


func stairs_at(x: int, z: int) -> String:
	var mark := _height_char(x, z)
	return mark if mark in STAIRS else ""


## Troca a altura de uma parede (acima do chão vizinho), no lugar da regra da frente e de trás.
func set_wall_height(x: int, z: int, wall_height: int) -> void:
	_wall_heights[Vector2i(x, z)] = wall_height
	if _tops.has(Vector2i(x, z)):
		_tops[Vector2i(x, z)] = _desired_top(x, z)


## Beiradas: blocos de chão mais altos que um vizinho, sem escada subindo dele até aqui. O gerador põe nelas um
## enfeite (moita, pedra) que segura quem anda: não há quedas, só se sobe e desce pelas escadas.
func ledges() -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for key: Vector2i in _heights:
		if not is_floor(key.x, key.y) or stairs_at(key.x, key.y) != "":
			continue
		for side_step in SIDES:
			var other := key + side_step
			if not is_floor(other.x, other.y) or _heights[other] >= _heights[key]:
				continue
			var mark := stairs_at(other.x, other.y)
			if mark != "" and STAIR_DIRECTIONS[mark] == -side_step and _heights[other] + 1 == _heights[key]:
				continue
			found.append(key)
			break
	return found


## A parede fica na frente da câmera quando o chão está a oeste ou ao norte dela (a câmera olha do sudeste).
func is_front(x: int, z: int) -> bool:
	return is_walkable(x - 1, z) or is_walkable(x, z - 1) or is_walkable(x - 1, z - 1) \
		or is_chasm(x - 1, z) or is_chasm(x, z - 1)


## Número fixo e sem padrão de cada bloco, para variar alturas e enfeites.
static func noise(x: int, z: int) -> int:
	return absi(hash(Vector2i(x, z)))


## Fração fixa e sem padrão de cada bloco, de 0 a 1.
static func chance(x: int, z: int, salt := 0) -> float:
	return float(absi(hash(Vector3i(x, z, salt))) % 10000) / 10000.0


## O fundo da coluna: desce até o topo mais baixo das vizinhas, para as laterais à vista ficarem cheias. Embaixo
## de uma ponte, conta o fundo do abismo.
func bottom(x: int, z: int) -> int:
	var lowest := _low_top(Vector2i(x, z))
	for side_step in SIDES:
		var other := Vector2i(x, z) + side_step
		if _tops.has(other):
			lowest = mini(lowest, _low_top(other))
	return lowest - 1


# O topo mais baixo de uma coluna: o do fundo do abismo, embaixo das pontes.
func _low_top(key: Vector2i) -> int:
	if kind(key.x, key.y) == Kind.BRIDGE:
		return height(key.x, key.y) - chasm_depth + 1
	return _tops.get(key, 0)


## Enche a coluna: o bloco de cima e, por baixo, o de enchimento, do fundo até o topo. Abaixo do chão mais perto,
## o enchimento pode ser outro, mais escuro ([param deep_item]), para o fundo parecer mais fundo.
func place_column(grid: GridMap, x: int, z: int, top_item: int, fill_item: int, deep_item := -1) -> void:
	var column_top := top(x, z)
	var deep_level := base(x, z) - 1
	for y in range(bottom(x, z), column_top - 1):
		grid.set_cell_item(Vector3i(x, y, z), deep_item if deep_item >= 0 and y < deep_level else fill_item)
	grid.set_cell_item(Vector3i(x, column_top - 1, z), top_item)


## O chão de um bloco, com a escada por cima, se houver.
func place_floor(grid: GridMap, x: int, z: int, top_item: int, fill_item: int, stairs_item: int) -> void:
	place_column(grid, x, z, top_item, fill_item)
	var stairs := stairs_at(x, z)
	if stairs != "":
		var facing: Vector2i = STAIR_DIRECTIONS[stairs]
		# A escada do jogo sobe para o norte (−z); as outras giram em volta do eixo de cima.
		var angle := atan2(-float(facing.x), -float(facing.y))
		grid.set_cell_item(Vector3i(x, height(x, z), z), stairs_item, grid.get_orthogonal_index_from_basis(Basis(Vector3.UP, angle)))


## A ponte: o tabuleiro em cima e, embaixo dele, o abismo continua, com o fundo ([param bottom_item] em cima do
## [param bed_item]); os pilares descem até o fundo a cada tantos blocos, nas beiradas.
func place_bridge(grid: GridMap, x: int, z: int, deck_item: int, support_item: int, support_every: int, bottom_item: int, bed_item: int) -> void:
	var h := height(x, z)
	grid.set_cell_item(Vector3i(x, h - 1, z), deck_item)
	var floor_top := _low_top(Vector2i(x, z))
	for y in range(bottom(x, z), floor_top - 1):
		grid.set_cell_item(Vector3i(x, y, z), bed_item)
	grid.set_cell_item(Vector3i(x, floor_top - 1, z), bottom_item)
	if support_every <= 0:
		return
	var along_x := _runs_along_x(x, z)
	var step := x if along_x else z
	var edge := (not is_bridge(x, z - 1) or not is_bridge(x, z + 1)) if along_x else (not is_bridge(x - 1, z) or not is_bridge(x + 1, z))
	if step % support_every == 0 and edge:
		for y in range(floor_top, h - 1):
			grid.set_cell_item(Vector3i(x, y, z), support_item)


## Blocos invisíveis que seguram os tiros e a visão em cima de uma parede baixa.
func place_sight(sight_grid: GridMap, x: int, z: int, invisible_item: int) -> void:
	if kind(x, z) != Kind.WALL:
		return
	for y in range(top(x, z), _neighbor_height(x, z) + sight_height):
		sight_grid.set_cell_item(Vector3i(x, y, z), invisible_item)


## Na beira dos abismos de dentro da área: a barreira que segura quem anda e a cerca virada para o chão.
## [param fence_item] fica na borda do bloco do lado do chão (a cerca do jogo fica na borda norte, −z).
func place_edge(barrier_grid: GridMap, decor_grid: GridMap, x: int, z: int, barrier_item: int, fence_item: int) -> void:
	if not is_chasm(x, z):
		return
	for side_step in SIDES:
		var other := Vector2i(x, z) + side_step
		if not is_walkable(other.x, other.y):
			continue
		var level := height(other.x, other.y)
		barrier_grid.set_cell_item(Vector3i(x, level, z), barrier_item)
		if fence_item >= 0 and decor_grid.get_cell_item(Vector3i(x, level, z)) == GridMap.INVALID_CELL_ITEM:
			var angle := atan2(-float(side_step.x), -float(side_step.y))
			decor_grid.set_cell_item(Vector3i(x, level, z), fence_item, decor_grid.get_orthogonal_index_from_basis(Basis(Vector3.UP, angle)))


## A malha da escada: 4 degraus, subindo para o norte (−z), dentro de um bloco centrado na origem.
static func stairs_mesh(material: Material) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for step in 4:
		var bottom_corner := Vector3(-0.5, -0.5, 0.5 - (step + 1) * 0.25)
		var top_corner := Vector3(0.5, -0.5 + (step + 1) * 0.25, 0.5 - step * 0.25)
		box(surface, bottom_corner, top_corner)
	surface.generate_normals()
	surface.set_material(material)
	surface.commit(mesh)
	return mesh


## A rampa da escada, para quem anda subir sem tropeçar nos degraus.
static func stairs_shape() -> ConvexPolygonShape3D:
	var shape := ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array([
		Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5), Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5),
		Vector3(-0.5, 0.5, -0.5), Vector3(0.5, 0.5, -0.5),
	])
	return shape


## Assa o mapa de navegação dos mobs: o topo de cada bloco de chão ou ponte livre (com bloco embaixo e nada em cima)
## e as rampas das escadas.
func bake_navigation(grid: GridMap) -> NavigationMesh:
	var faces := PackedVector3Array()
	for key: Vector2i in _heights:
		if not is_walkable(key.x, key.y):
			continue
		var h: int = _heights[key]
		var stairs := stairs_at(key.x, key.y)
		if stairs != "":
			_add_ramp_faces(faces, key, h, STAIR_DIRECTIONS[stairs])
			continue
		if grid.get_cell_item(Vector3i(key.x, h - 1, key.y)) == GridMap.INVALID_CELL_ITEM:
			continue
		if grid.get_cell_item(Vector3i(key.x, h, key.y)) != GridMap.INVALID_CELL_ITEM:
			continue
		var x := float(key.x)
		var z := float(key.y)
		var y := float(h)
		faces.append_array([Vector3(x, y, z), Vector3(x + 1, y, z), Vector3(x + 1, y, z + 1)])
		faces.append_array([Vector3(x, y, z), Vector3(x + 1, y, z + 1), Vector3(x, y, z + 1)])
	var source_data := NavigationMeshSourceGeometryData3D.new()
	source_data.add_faces(faces, Transform3D.IDENTITY)
	var navigation := NavigationMesh.new()
	navigation.cell_size = 0.25
	navigation.cell_height = 0.25
	navigation.agent_radius = 0.5
	navigation.agent_height = 1.75
	navigation.agent_max_climb = 0.25
	navigation.agent_max_slope = 46.0
	NavigationServer3D.bake_from_source_geometry_data(navigation, source_data)
	return navigation


## Uma caixa entre dois cantos, com as faces viradas para fora.
static func box(surface: SurfaceTool, from: Vector3, to: Vector3) -> void:
	var corners := [
		Vector3(from.x, from.y, from.z), Vector3(to.x, from.y, from.z), Vector3(to.x, to.y, from.z), Vector3(from.x, to.y, from.z),
		Vector3(from.x, from.y, to.z), Vector3(to.x, from.y, to.z), Vector3(to.x, to.y, to.z), Vector3(from.x, to.y, to.z),
	]
	var center := (from + to) / 2.0
	for quad: Array in [[3, 2, 1, 0], [4, 5, 6, 7], [7, 6, 2, 3], [0, 1, 5, 4], [1, 2, 6, 5], [4, 7, 3, 0]]:
		var a: Vector3 = corners[quad[0]]
		var b: Vector3 = corners[quad[1]]
		var c: Vector3 = corners[quad[2]]
		var d: Vector3 = corners[quad[3]]
		# A frente para fora: no Godot, o sentido horário visto de fora (o produto vetorial aponta para dentro).
		var outward := (a + c) / 2.0 - center
		var points := [a, b, c, a, c, d]
		if (b - a).cross(c - a).dot(outward) > 0.0:
			points = [a, c, b, a, d, c]
		for point: Vector3 in points:
			surface.set_uv(Vector2(point.x + point.z, -point.y))
			surface.add_vertex(point)


static func _add_ramp_faces(faces: PackedVector3Array, column: Vector2i, base_height: int, facing: Vector2i) -> void:
	var x := float(column.x)
	var z := float(column.y)
	var low_y := float(base_height)
	var high_y := float(base_height + 1)
	# A beirada de cima da rampa fica do lado para onde ela sobe.
	var corners := [Vector3(x, 0, z), Vector3(x + 1, 0, z), Vector3(x + 1, 0, z + 1), Vector3(x, 0, z + 1)]
	for i in corners.size():
		var corner: Vector3 = corners[i]
		var offset := Vector2(corner.x - x - 0.5, corner.z - z - 0.5)
		corners[i].y = high_y if offset.dot(Vector2(facing)) > 0.0 else low_y
	faces.append_array([corners[0], corners[1], corners[2]])
	faces.append_array([corners[0], corners[2], corners[3]])


# A ponte vai na direção em que as duas pontas dão em chão.
func _runs_along_x(x: int, z: int) -> bool:
	var west := x
	while is_bridge(west - 1, z):
		west -= 1
	var east := x
	while is_bridge(east + 1, z):
		east += 1
	return is_floor(west - 1, z) and is_floor(east + 1, z)


func _read_kind(x: int, z: int) -> Kind:
	var mark := cell(x, z)
	if mark in chasm_chars:
		return Kind.CHASM
	if mark in floor_chars:
		return Kind.BRIDGE if _height_char(x, z) in BRIDGES else Kind.FLOOR
	return Kind.FILL


func _height_char(x: int, z: int) -> String:
	if z < 0 or z >= height_rows.size() or x < 0 or x >= height_rows[z].length():
		return "0"
	return height_rows[z][x]


func _read_height(x: int, z: int) -> int:
	var mark := _height_char(x, z)
	if mark in STAIRS:
		# A escada começa na altura do bloco de baixo, do lado contrário ao que ela sobe.
		var facing: Vector2i = STAIR_DIRECTIONS[mark]
		var below := _height_char(x - facing.x, z - facing.y)
		return int(below) if below.is_valid_int() else 0
	if mark in BRIDGES:
		return BRIDGES.find(mark)
	return int(mark) if mark.is_valid_int() else 0


# A altura de cada coluna antes dos ajustes de cada área.
func _desired_top(x: int, z: int) -> int:
	match kind(x, z):
		Kind.FLOOR, Kind.BRIDGE:
			return height(x, z)
		Kind.CHASM:
			return height(x, z) - chasm_depth + 1
		Kind.WALL:
			var wall_base := _neighbor_height(x, z)
			var front := is_front(x, z)
			var wall_rise: int = _wall_heights.get(Vector2i(x, z), front_height if front else back_height + noise(x, z) % (back_variation + 1))
			return maxi(mini(wall_base + wall_rise, cap(x, z)), wall_base + 1)
	# O resto: morro atrás, abismo na frente, e uma transição de lado.
	var fill_base := base(x, z)
	var steps := distance(x, z)
	var mountain := fill_base + back_height + int(rise * float(steps - 1)) + noise(x, z) % 3
	mountain = mini(mountain, fill_base + peak)
	var valley := fill_base - chasm_depth + 1
	if chance(x, z, 1) < island_chance:
		valley = fill_base - island_top - noise(x, z) % 3
	var weight := smoothstep(-0.35, 0.35, side(x, z))
	if _behind.get(Vector2i(x, z), 999) <= front_reach:
		weight = 1.0
	return mini(roundi(lerpf(float(mountain), float(valley), weight)), cap(x, z))


func _touches_walkable(x: int, z: int) -> bool:
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if (dx != 0 or dz != 0) and is_walkable(x + dx, z + dz):
				return true
	return false


func _neighbor_height(x: int, z: int) -> int:
	var best := -99
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if _heights.has(Vector2i(x + dx, z + dz)):
				best = maxi(best, height(x + dx, z + dz))
	return best if best > -99 else base(x, z)


# Distância de cada bloco até o bloco jogável mais perto, contando em quadrados, e qual é esse bloco.
func _measure_distances() -> void:
	var frontier: Array[Vector2i] = []
	for key: Vector2i in _heights:
		_distance[key] = 0
		_source[key] = key
		frontier.append(key)
	var steps := 0
	while not frontier.is_empty():
		steps += 1
		var next: Array[Vector2i] = []
		for here in frontier:
			for dz in range(-1, 2):
				for dx in range(-1, 2):
					var there := here + Vector2i(dx, dz)
					if _distance.has(there) or there.x < low.x or there.y < low.y or there.x >= high.x or there.y >= high.y:
						continue
					_distance[there] = steps
					_source[there] = _source[here]
					next.append(there)
		frontier = next


# O teto da visão de cada coluna fora do chão: a câmera olha do sudeste, a 45°, então uma coluna só esconde o chão
# que fica atrás dela na diagonal. A coluna pode subir até a linha que vai do peito de Nate até a câmera.
func _measure_caps() -> void:
	var reach := int(ceil((float(peak) + 2.0) / 0.70710678 / 2.0)) + 1
	for z in range(low.y, high.y):
		for x in range(low.x, high.x):
			var key := Vector2i(x, z)
			if _heights.has(key):
				continue
			var best := 999.0
			for k in range(1, maxi(reach, front_reach) + 1):
				for offset: Vector2i in [Vector2i(k, k), Vector2i(k, k - 1), Vector2i(k - 1, k)]:
					var behind := key - offset
					if not _heights.has(behind) or not is_walkable(behind.x, behind.y):
						continue
					if not _behind.has(key):
						_behind[key] = k
					var limit := float(_heights[behind]) + view_height + 0.70710678 * float(offset.x + offset.y)
					best = minf(best, limit)
			if best < 999.0:
				_caps[key] = floori(best)
