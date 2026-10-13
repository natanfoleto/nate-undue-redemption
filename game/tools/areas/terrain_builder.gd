extends RefCounted
# Montador do terreno das áreas (usado por make_mine, make_forest e make_ruins). Lê dois rascunhos em texto, com um
# caractere por bloco (x para a direita, z para baixo, o norte em cima):
# - o do mapa diz o que é chão (com os objetos em cima), abismo ou o resto (parede, rocha, vazio);
# - o das alturas diz a altura do chão: um dígito é a altura; n, s, e e w são escadas de pedra que sobem para aquele
#   lado, a partir da altura do bloco de baixo (nas construções); ^, v, > e < são rampas do próprio chão, que sobem
#   para o norte, o sul, o leste e o oeste (na natureza): de 1 a 3 blocos seguidos na mesma direção sobem 1 bloco,
#   e quanto mais longa, mais suave; de A a J, ponte na altura 0 a 9.
# Com auto_ramps (na natureza), todo desnível de 1 bloco entre dois chões vira rampa curta do próprio chão, também
# nos cantos: os morros sobem de qualquer lado, sem escada nem moita na beirada.
#
# Em volta do chão, o terreno preenche tudo até a margem, para a câmera nunca ver o vazio: rente ao chão, a parede
# (baixa na frente da câmera, alta e irregular atrás); depois, morros subindo atrás e abismos descendo na frente, com
# o fundo de cada área (água, fungos, lava). Nada pode tampar a visão de Nate: a altura de cada coluna tem um teto,
# o da linha de visão da câmera até o chão atrás dela.

const STAIRS := "nsew"
const STAIR_DIRECTIONS := {"n": Vector2i(0, -1), "s": Vector2i(0, 1), "e": Vector2i(1, 0), "w": Vector2i(-1, 0)}
const RAMPS := "^v><"
const RAMP_DIRECTIONS := {"^": Vector2i(0, -1), "v": Vector2i(0, 1), ">": Vector2i(1, 0), "<": Vector2i(-1, 0)}
## Rampas mais longas que isso não têm peças na biblioteca.
const MAX_RAMP := 3
const BRIDGES := "ABCDEFGHIJ"
const SIDES: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIAGONALS: Array[Vector2i] = [Vector2i(1, -1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, 1)]
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
# Desníveis de 1 bloco entre chões viram rampas sozinhos (na natureza; nas construções, só escadas e rampas do
# rascunho).
var auto_ramps := false
# Caracteres do rascunho onde a rampa automática pode surgir: o chão sem nada em cima (um objeto ou um mob numa rampa
# ficaria meio enterrado). Vazio, qualquer chão.
var slope_chars := ""

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
# As rampas que surgem sozinhas: a direção (para um lado, ou a diagonal dos cantos) e o tipo de canto.
var _slopes := {}


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
	if auto_ramps:
		_find_slopes()
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


## A rampa do bloco: a direção para onde sobe, a peça (0 é a de baixo), quantas peças ela tem e o canto ("inner",
## o canto de dentro, que sobe para dois lados; "outer", o de fora, que sobe só na ponta; vazio na rampa reta). Nos
## cantos, a direção é a diagonal. Sem rampa, vazio.
func ramp_at(x: int, z: int) -> Dictionary:
	var mark := _height_char(x, z)
	if mark == "" or mark not in RAMPS:
		return _slopes.get(Vector2i(x, z), {})
	var facing: Vector2i = RAMP_DIRECTIONS[mark]
	var step := 0
	while _height_char(x - facing.x * (step + 1), z - facing.y * (step + 1)) == mark:
		step += 1
	var length := step + 1
	while _height_char(x + facing.x * (length - step), z + facing.y * (length - step)) == mark:
		length += 1
	return {"facing": facing, "step": step, "length": length, "corner": ""}


## Nome da peça de rampa de um bloco na biblioteca (make_blocks.gd): "Grama rampa 1/2" é a de baixo de uma rampa de 2;
## os cantos são "Grama rampa canto de dentro" e "Grama rampa canto de fora".
static func ramp_name(block_name: String, step: int, length: int, corner := "") -> String:
	if corner != "":
		return "%s rampa canto de %s" % [block_name, "dentro" if corner == "inner" else "fora"]
	return "%s rampa %d/%d" % [block_name, step + 1, length]


# Rampas que surgem sozinhas no chão de baixo de cada desnível de 1 bloco: reta, com um vizinho mais alto; canto de
# dentro, com dois vizinhos mais altos lado a lado; canto de fora, só com o vizinho da diagonal mais alto e os dois
# do lado na mesma altura (eles viram rampas retas).
func _find_slopes() -> void:
	for key: Vector2i in _heights:
		if not _can_slope(key):
			continue
		var level: int = _heights[key]
		var higher: Array[Vector2i] = []
		for side_step in SIDES:
			if _is_plain_floor(key + side_step) and _heights[key + side_step] == level + 1:
				higher.append(side_step)
		if higher.size() == 1:
			_slopes[key] = {"facing": higher[0], "step": 0, "length": 1, "corner": ""}
		elif higher.size() == 2 and higher[0] != -higher[1]:
			_slopes[key] = {"facing": higher[0] + higher[1], "step": 0, "length": 1, "corner": "inner"}
		elif higher.is_empty():
			var tips: Array[Vector2i] = []
			for diagonal in DIAGONALS:
				var tip := key + diagonal
				var beside_x := key + Vector2i(diagonal.x, 0)
				var beside_z := key + Vector2i(0, diagonal.y)
				if _is_plain_floor(tip) and _heights[tip] == level + 1 and _can_slope(beside_x) \
						and _heights[beside_x] == level and _can_slope(beside_z) and _heights[beside_z] == level:
					tips.append(diagonal)
			if tips.size() == 1:
				_slopes[key] = {"facing": tips[0], "step": 0, "length": 1, "corner": "outer"}


# Chão comum: sem escada, rampa do rascunho nem ponte.
func _is_plain_floor(spot: Vector2i) -> bool:
	return is_floor(spot.x, spot.y) and _height_char(spot.x, spot.y).is_valid_int()


# Onde a rampa automática pode surgir: chão comum sem objeto em cima.
func _can_slope(spot: Vector2i) -> bool:
	return _is_plain_floor(spot) and (slope_chars == "" or cell(spot.x, spot.y) in slope_chars)


## Troca a altura de uma parede (acima do chão vizinho), no lugar da regra da frente e de trás.
func set_wall_height(x: int, z: int, wall_height: int) -> void:
	_wall_heights[Vector2i(x, z)] = wall_height
	if _tops.has(Vector2i(x, z)):
		_tops[Vector2i(x, z)] = _desired_top(x, z)


## Beiradas: blocos de chão mais altos que um vizinho, sem escada nem rampa subindo dele até aqui. O gerador põe
## nelas um enfeite (moita, pedra) que segura quem anda: não há quedas, só se sobe e desce pelas escadas e rampas.
func ledges() -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for key: Vector2i in _heights:
		if not is_floor(key.x, key.y) or stairs_at(key.x, key.y) != "" or not ramp_at(key.x, key.y).is_empty():
			continue
		for side_step in SIDES:
			var other := key + side_step
			if not is_floor(other.x, other.y) or _heights[other] >= _heights[key]:
				continue
			if _heights[other] + 1 == _heights[key] and _climbs_to(other, -side_step):
				continue
			found.append(key)
			break
	return found


# Se do bloco dá para subir até o vizinho daquele lado: escada virada para ele, a última peça de uma rampa reta ou um
# canto de dentro, que sobe para os dois lados dele.
func _climbs_to(spot: Vector2i, toward: Vector2i) -> bool:
	var mark := stairs_at(spot.x, spot.y)
	if mark != "":
		return STAIR_DIRECTIONS[mark] == toward
	var ramp := ramp_at(spot.x, spot.y)
	if ramp.is_empty():
		return false
	if ramp.corner == "inner":
		return toward == Vector2i(ramp.facing.x, 0) or toward == Vector2i(0, ramp.facing.y)
	return ramp.corner == "" and ramp.facing == toward and ramp.step == ramp.length - 1


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


## Ruído suave de 0 a 1: valores sorteados numa grade de [param scale] blocos, misturados entre os cantos. Faz
## morros e bordas ondulados, sem o jeito de quadrado das distâncias contadas em blocos.
static func smooth_noise(x: float, z: float, scale: float, salt := 0) -> float:
	var gx := x / scale
	var gz := z / scale
	var x0 := floori(gx)
	var z0 := floori(gz)
	var tx := smoothstep(0.0, 1.0, gx - x0)
	var tz := smoothstep(0.0, 1.0, gz - z0)
	var top := lerpf(chance(x0, z0, salt), chance(x0 + 1, z0, salt), tx)
	var down := lerpf(chance(x0, z0 + 1, salt), chance(x0 + 1, z0 + 1, salt), tx)
	return lerpf(top, down, tz)


## Um bloco perto deste, puxado por um ruído suave (até [param reach] blocos, às vezes um a mais): quando cada bloco
## usa o chão do bloco puxado, a borda entre dois chões fica ondulada e misturada, em vez de uma linha reta. Só serve
## o bloco ligado a este por chão (blend_source).
static func warp(x: int, z: int, reach := 2, salt := 0) -> Vector2i:
	var dx := roundi((smooth_noise(x, z, 4.0, salt) * 2.0 - 1.0) * reach * 1.6)
	var dz := roundi((smooth_noise(x, z, 4.0, salt + 1) * 2.0 - 1.0) * reach * 1.6)
	if chance(x, z, salt + 2) < 0.12:
		dx += 1 if chance(x, z, salt + 3) < 0.5 else -1
	return Vector2i(x + clampi(dx, -reach - 1, reach + 1), z + clampi(dz, -reach - 1, reach + 1))


## De qual bloco de chão este pega o material, na borda misturada entre dois chões (warp): o bloco puxado, se a reta
## até ele só passa por chão (nada vem do outro lado de uma parede); senão, ele mesmo.
func blend_source(x: int, z: int, reach := 2, salt := 0) -> Vector2i:
	var target := warp(x, z, reach, salt)
	var offset := Vector2(target - Vector2i(x, z))
	var steps := ceili(offset.length() * 2.0)
	for i in range(1, steps + 1):
		var point := Vector2(x + 0.5, z + 0.5) + offset * (float(i) / steps)
		if not is_floor(floori(point.x), floori(point.y)):
			return Vector2i(x, z)
	return target


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


## O chão de um bloco, com a escada ou a peça de rampa por cima, se houver. A rampa é do mesmo bloco do chão: a peça
## sai da biblioteca pelo nome (ramp_name).
func place_floor(grid: GridMap, x: int, z: int, top_item: int, fill_item: int, stairs_item: int) -> void:
	place_column(grid, x, z, top_item, fill_item)
	var stairs := stairs_at(x, z)
	var ramp := ramp_at(x, z)
	var facing := Vector2i.ZERO
	var item := -1
	if stairs != "":
		facing = STAIR_DIRECTIONS[stairs]
		item = stairs_item
	elif not ramp.is_empty():
		facing = ramp.facing
		var piece := ramp_name(grid.mesh_library.get_item_name(top_item), ramp.step, ramp.length, ramp.corner)
		item = grid.mesh_library.find_item_by_name(piece)
		assert(item >= 0, "peça de rampa que falta na biblioteca: " + piece)
	if item >= 0:
		# A escada e a rampa da biblioteca sobem para o norte (−z), e os cantos, para o nordeste; as outras giram em
		# volta do eixo de cima.
		var angle := atan2(-float(facing.x), -float(facing.y))
		if facing.x != 0 and facing.y != 0:
			angle += PI / 4.0
		grid.set_cell_item(Vector3i(x, height(x, z), z), item, grid.get_orthogonal_index_from_basis(Basis(Vector3.UP, angle)))


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
	return ramp_shape(0, 1)


## Peça [param step] (0 é a de baixo) de uma rampa de [param length] blocos, subindo para o norte (−z): a base cheia
## até a altura da peça anterior e, em cima, o chão inclinado. A face de cima usa [param top] (sem projeção do mundo,
## para a textura seguir a inclinação); as laterais, [param side].
static func ramp_mesh(step: int, length: int, top: Material, side: Material) -> ArrayMesh:
	var low_y := -0.5 + float(step) / length
	var high_y := -0.5 + float(step + 1) / length
	var mesh := ArrayMesh.new()
	var slope := SurfaceTool.new()
	slope.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners := [Vector3(-0.5, high_y, -0.5), Vector3(0.5, high_y, -0.5), Vector3(0.5, low_y, 0.5), Vector3(-0.5, low_y, 0.5)]
	var uvs := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	for index: int in [0, 1, 2, 0, 2, 3]:
		slope.set_uv(uvs[index])
		slope.add_vertex(corners[index])
	slope.generate_normals()
	slope.set_material(top)
	slope.commit(mesh)
	var sides := SurfaceTool.new()
	sides.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x: float in [-0.5, 0.5]:
		var quad := [Vector3(x, -0.5, 0.5), Vector3(x, -0.5, -0.5), Vector3(x, high_y, -0.5), Vector3(x, low_y, 0.5)]
		_add_quad(sides, quad, Vector3(x, 0.0, 0.0))
	_add_quad(sides, [Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5), Vector3(0.5, high_y, -0.5), Vector3(-0.5, high_y, -0.5)], Vector3.FORWARD)
	if step > 0:
		_add_quad(sides, [Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5), Vector3(0.5, low_y, 0.5), Vector3(-0.5, low_y, 0.5)], Vector3.BACK)
	sides.generate_normals()
	sides.set_material(side)
	sides.commit(mesh)
	return mesh


## Peça do canto de uma rampa curta, subindo para o nordeste (+x, −z). O canto de dentro ([param inner]) fica alto em
## três pontas e desce até a ponta sudoeste; o de fora fica baixo em três pontas e sobe só na ponta nordeste (o resto
## é o chão de baixo, que aparece por baixo).
static func corner_mesh(inner: bool, top: Material, side: Material) -> ArrayMesh:
	var low := -0.5
	var high := 0.5
	var nw := Vector3(-0.5, high if inner else low, -0.5)
	var ne := Vector3(0.5, high, -0.5)
	var se := Vector3(0.5, high if inner else low, 0.5)
	var sw := Vector3(-0.5, low, 0.5)
	var mesh := ArrayMesh.new()
	var slope := SurfaceTool.new()
	slope.begin(Mesh.PRIMITIVE_TRIANGLES)
	_add_triangle(slope, nw, ne, se, Vector3.UP, true)
	if inner:
		_add_triangle(slope, nw, se, sw, Vector3.UP, true)
	slope.generate_normals()
	slope.set_material(top)
	slope.commit(mesh)
	var sides := SurfaceTool.new()
	sides.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bottom_nw := Vector3(-0.5, low, -0.5)
	var bottom_ne := Vector3(0.5, low, -0.5)
	var bottom_se := Vector3(0.5, low, 0.5)
	if inner:
		_add_triangle(sides, sw, bottom_nw, nw, Vector3.LEFT, false)
		_add_triangle(sides, sw, bottom_se, se, Vector3.BACK, false)
		_add_quad(sides, [bottom_nw, bottom_ne, ne, nw], Vector3.FORWARD)
		_add_quad(sides, [bottom_ne, bottom_se, se, ne], Vector3.RIGHT)
	else:
		_add_triangle(sides, bottom_nw, bottom_ne, ne, Vector3.FORWARD, false)
		_add_triangle(sides, bottom_ne, bottom_se, ne, Vector3.RIGHT, false)
	sides.generate_normals()
	sides.set_material(side)
	sides.commit(mesh)
	return mesh


## A forma do canto, para pisar nele. O de fora não é convexo: vai como malha de faces.
static func corner_shape(inner: bool) -> Shape3D:
	if inner:
		var convex := ConvexPolygonShape3D.new()
		convex.points = PackedVector3Array([
			Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5), Vector3(0.5, -0.5, 0.5), Vector3(-0.5, -0.5, 0.5),
			Vector3(-0.5, 0.5, -0.5), Vector3(0.5, 0.5, -0.5), Vector3(0.5, 0.5, 0.5),
		])
		return convex
	var faces := ConcavePolygonShape3D.new()
	faces.backface_collision = true
	var ne := Vector3(0.5, 0.5, -0.5)
	faces.set_faces(PackedVector3Array([
		Vector3(-0.5, -0.5, -0.5), ne, Vector3(0.5, -0.5, 0.5),
		Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5), ne,
		Vector3(0.5, -0.5, -0.5), Vector3(0.5, -0.5, 0.5), ne,
	]))
	return faces


# Um triângulo com a frente para [param outward]; [param flat_uv] mapeia a textura de cima (x, z), um quadro por bloco.
static func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, outward: Vector3, flat_uv: bool) -> void:
	var points := [a, b, c]
	if (b - a).cross(c - a).dot(outward) > 0.0:
		points = [a, c, b]
	for point: Vector3 in points:
		surface.set_uv(Vector2(point.x + 0.5, point.z + 0.5) if flat_uv else Vector2(point.x + point.z, -point.y))
		surface.add_vertex(point)


## A forma da peça de rampa, para pisar nela.
static func ramp_shape(step: int, length: int) -> ConvexPolygonShape3D:
	var low_y := -0.5 + float(step) / length
	var high_y := -0.5 + float(step + 1) / length
	var shape := ConvexPolygonShape3D.new()
	var points := PackedVector3Array([
		Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5), Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5),
		Vector3(-0.5, high_y, -0.5), Vector3(0.5, high_y, -0.5),
	])
	if step > 0:
		points.append_array([Vector3(-0.5, low_y, 0.5), Vector3(0.5, low_y, 0.5)])
	shape.points = points
	return shape


# Um quadrilátero com a frente para [param outward] (no Godot, o sentido horário visto de fora).
static func _add_quad(surface: SurfaceTool, quad: Array, outward: Vector3) -> void:
	var a: Vector3 = quad[0]
	var b: Vector3 = quad[1]
	var c: Vector3 = quad[2]
	var d: Vector3 = quad[3]
	var points := [a, b, c, a, c, d]
	if (b - a).cross(c - a).dot(outward) > 0.0:
		points = [a, c, b, a, d, c]
	for point: Vector3 in points:
		surface.set_uv(Vector2(point.x + point.z, -point.y))
		surface.add_vertex(point)


## Assa o mapa de navegação dos mobs: o topo de cada bloco de chão ou ponte livre (com bloco embaixo e nada em cima)
## e as rampas, as do chão e as das escadas.
func bake_navigation(grid: GridMap) -> NavigationMesh:
	var faces := PackedVector3Array()
	for key: Vector2i in _heights:
		if not is_walkable(key.x, key.y):
			continue
		var h: int = _heights[key]
		var stairs := stairs_at(key.x, key.y)
		if stairs != "":
			_add_ramp_faces(faces, key, h, STAIR_DIRECTIONS[stairs], 0.0, 1.0)
			continue
		var ramp := ramp_at(key.x, key.y)
		if not ramp.is_empty():
			if ramp.corner != "":
				_add_corner_faces(faces, key, h, ramp.facing, ramp.corner == "inner")
			else:
				_add_ramp_faces(faces, key, h, ramp.facing, float(ramp.step) / ramp.length, float(ramp.step + 1) / ramp.length)
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


static func _add_ramp_faces(faces: PackedVector3Array, column: Vector2i, base_height: int, facing: Vector2i, low_rise: float, high_rise: float) -> void:
	var x := float(column.x)
	var z := float(column.y)
	var low_y := float(base_height) + low_rise
	var high_y := float(base_height) + high_rise
	# A beirada de cima da rampa fica do lado para onde ela sobe.
	var corners := [Vector3(x, 0, z), Vector3(x + 1, 0, z), Vector3(x + 1, 0, z + 1), Vector3(x, 0, z + 1)]
	for i in corners.size():
		var corner: Vector3 = corners[i]
		var offset := Vector2(corner.x - x - 0.5, corner.z - z - 0.5)
		corners[i].y = high_y if offset.dot(Vector2(facing)) > 0.0 else low_y
	faces.append_array([corners[0], corners[1], corners[2]])
	faces.append_array([corners[0], corners[2], corners[3]])


# O chão do canto para a navegação: as pontas altas a 1 bloco acima, divididas na diagonal que não passa pela ponta
# diferente (a baixa, no de dentro; a alta, no de fora).
static func _add_corner_faces(faces: PackedVector3Array, column: Vector2i, base_height: int, diagonal: Vector2i, inner: bool) -> void:
	var corners: Array[Vector3] = []
	var special := -1
	for sign_pair: Vector2i in [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]:
		var tip := sign_pair == diagonal
		var opposite := sign_pair == -diagonal
		var raised := (not opposite) if inner else tip
		if (inner and opposite) or (not inner and tip):
			special = corners.size()
		corners.append(Vector3(column.x + (sign_pair.x + 1) / 2, base_height + (1 if raised else 0), column.y + (sign_pair.y + 1) / 2))
	var before := corners[(special + 3) % 4]
	var after := corners[(special + 1) % 4]
	for triangle: Array in [[corners[special], after, before], [after, corners[(special + 2) % 4], before]]:
		var a: Vector3 = triangle[0]
		var b: Vector3 = triangle[1]
		var c: Vector3 = triangle[2]
		# De frente para cima, como os outros pedaços do chão.
		if (b - a).cross(c - a).y > 0.0:
			faces.append_array([a, c, b])
		else:
			faces.append_array([a, b, c])


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
	if mark in RAMPS:
		# Todas as peças da rampa ficam na altura do chão de baixo, antes da primeira peça.
		var facing: Vector2i = RAMP_DIRECTIONS[mark]
		var back := Vector2i(x, z) - facing
		while _height_char(back.x, back.y) == mark:
			back -= facing
		var below := _height_char(back.x, back.y)
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
	# O resto: morro atrás, abismo na frente, e uma transição de lado. A distância é a reta até o chão mais perto, e
	# um ruído suave ondula os morros e a divisa com os abismos, para nada ficar com jeito de quadrado.
	var fill_base := base(x, z)
	var reach := Vector2(Vector2i(x, z) - source(x, z)).length()
	var bumps := roundi(smooth_noise(x, z, 5.0, 7) * 4.0 - 1.0) + noise(x, z) % 2
	var mountain := fill_base + back_height + int(rise * maxf(reach - 1.0, 0.0)) + bumps
	mountain = mini(mountain, fill_base + peak)
	var valley := fill_base - chasm_depth + 1
	if chance(x, z, 1) < island_chance:
		valley = fill_base - island_top - noise(x, z) % 3
	var weight := smoothstep(-0.35, 0.35, side(x, z) + (smooth_noise(x, z, 6.0, 9) - 0.5) * 0.7)
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
