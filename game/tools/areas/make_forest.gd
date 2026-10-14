extends SceneTree
# Monta o Bosque de Fungos (world/areas/forest.tscn) a partir dos rascunhos em texto (forest_layout.txt e
# forest_heights.txt; o montador do terreno explica o formato). Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_forest.gd
#
# Em volta das salas, rocha azulada subindo em morros, com cogumelos gigantes em cima; na frente da câmera, fendas
# com água que brilha e fungos acesos lá no fundo.

const FOLDER := "res://tools/areas/"
const LAYOUT := FOLDER + "forest_layout.txt"
const HEIGHTS := FOLDER + "forest_heights.txt"
const BUILDER := FOLDER + "terrain_builder.gd"
const NAVIGATION_PATH := "res://world/areas/forest_navigation.res"
const AREA_PATH := "res://world/areas/forest.tscn"

# Caracteres do rascunho que são chão (onde se anda ou onde fica um objeto em cima do chão). A fenda (~) é abismo.
const FLOOR_CHARS := ",.12ACDFHKLNUVWXabcdefghjkopqsuxz"
# Altura do pé dos cogumelos gigantes e da parede rachada; a tampa das áreas escuras fica logo acima das paredes
# baixas em volta delas.
const STEM_HEIGHT := 3
const CRACKED_HEIGHT := 2
const DARK_WALL_HEIGHT := 2
const CYAN := Color("4fe3d0")
const LIME := Color("b8f060")
# Melhorias: identificador no mapa (começa com o tipo) e tipo. O desvio a oeste do corredor norte guarda +1 carga;
# o canto escuro ao lado da sala do Fogo e o desvio cercado de cogumelos, +20 de vida.
const UPGRADES := {
	"h": [&"heart_forest_1", &"heart"],
	"H": [&"heart_forest_2", &"heart"],
	"z": [&"charge_forest_1", &"charge"],
	"j": [&"heart_forest_3", &"heart"],
	"c": [&"heart_forest_4", &"heart"],
}
# Luzes do fundo das fendas: uma a cada tantos blocos, até esta distância do chão.
const BOTTOM_LIGHT_EVERY := 7
const BOTTOM_LIGHT_REACH := 9
# O Bosque vivo, como as florestas do Minecraft Dungeons (08-mapa): o chão em manchas de musgo (claro, médio e escuro)
# e de terra com cascalho, no tamanho do ruído; no chão de dentro, plantas perto das paredes, nas manchas de musgo e
# um pouco na terra, e flores que brilham; nos morros, arbustos, plantas, troncos caídos e ruínas com musgo. Partes
# de 0 a 1.
const PATCH_SCALE := 5.0
const GRAVEL_SCALE := 4.0
const EDGE_PLANTS := 0.55
const MOSS_PLANTS := 0.3
const DIRT_PLANTS := 0.06
const GLOW_FLOWERS := 0.05
const HILL_BUSHES := 0.1
const HILL_PLANTS := 0.25
const HILL_LOGS := 0.012
const HILL_RUINS := 0.01
const LOG_LENGTH := 3
# Cipós debaixo da borda dos chapéus dos cogumelos gigantes: a parte que tem e a que desce 2 blocos.
const VINES := 0.5
const LONG_VINES := 0.3
# Riachos rasos que brilham, de uma parede a outra ou até a fenda: os pontos por onde cada um passa. Não passam em
# objetos nem em rampas; correm sem buracos (sem ligar blocos só pelo canto), às vezes com 2 blocos de largura, e têm
# mais plantas nas margens.
const STREAMS := [
	[Vector2i(52, 2), Vector2i(50, 8), Vector2i(53, 14), Vector2i(50, 20), Vector2i(46, 26), Vector2i(45, 28)],
	[Vector2i(4, 62), Vector2i(9, 69), Vector2i(11, 73)],
	[Vector2i(44, 36), Vector2i(46, 42), Vector2i(43, 48)],
]
const STREAM_WIDE := 0.62
const BANK_PLANTS := 0.45
# Esporos que flutuam no ar do Bosque: um grupo a cada tantos blocos de chão.
const SPORES_EVERY := 9

var _rows: PackedStringArray
var _root: Node3D
var _library: MeshLibrary
var _terrain: GridMap
var _sight: GridMap
var _barriers: GridMap
var _decor: GridMap
var _land: RefCounted
var _objects: Node3D
var _items := {}
var _counts := {}
var _mushrooms := 0
var _streams := {}


func _initialize() -> void:
	_rows = FileAccess.get_file_as_string(LAYOUT).split("\n")
	_root = (load("res://world/area_level.gd") as GDScript).new()
	_root.name = "Forest"
	_root.set("music", load("res://assets/audio/music/spacetime.mp3"))
	_build_lighting()
	_build_terrain()
	var player := _build_player()
	_build_objects()
	_build_dark_areas()
	_build_interface(player)
	var scene := PackedScene.new()
	scene.pack(_root)
	print(AREA_PATH, ": ", error_string(ResourceSaver.save(scene, AREA_PATH)))
	_root.free()
	quit()


func _cell(x: int, z: int) -> String:
	if z < 0 or z >= _rows.size() or x < 0 or x >= _rows[z].length():
		return " "
	return _rows[z][x]


func _center(x: float, z: float) -> Vector3:
	return Vector3(x + 0.5, _ground(x, z), z + 0.5)


# Altura do chão debaixo de um ponto do mapa.
func _ground(x: float, z: float) -> int:
	return _land.ground(floori(x), floori(z))


# Bloco da biblioteca pelo nome (make_blocks.gd).
func _item(item_name: String) -> int:
	if not _items.has(item_name):
		var index := _library.find_item_by_name(item_name)
		assert(index >= 0, "bloco que falta na biblioteca: " + item_name)
		_items[item_name] = index
	return _items[item_name]


# Embaixo da terra: sem sol, luz ambiente fraca e azulada; a luz vem dos fungos (10-arte-audio).
func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("070a10")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.65, 0.85)
	environment.ambient_light_energy = 0.85
	environment.glow_enabled = true
	environment.glow_intensity = 0.6
	environment.glow_bloom = 0.05
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	world.environment = environment
	_add(_root, world)


func _build_terrain() -> void:
	_library = load("res://world/blocks/forest_blocks.tres")
	_terrain = _grid("Terrain", HitShape.WORLD_LAYER)
	# Blocos invisíveis em cima das paredes baixas: seguram os tiros e a visão, como as outras paredes.
	_sight = _grid("Sight", HitShape.WORLD_LAYER)
	# Barreiras invisíveis na beira da fenda: seguram quem anda, mas não os tiros nem a visão.
	_barriers = _grid("Barriers", HitShape.BARRIER_LAYER)
	# Enfeites sem colisão: cercas e cogumelos pequenos.
	_decor = _grid("Decor", 0)
	_land = (load(BUILDER) as GDScript).new()
	_land.floor_chars = FLOOR_CHARS
	_land.auto_ramps = true
	_land.slope_chars = ".,"
	_land.setup(_rows, FileAccess.get_file_as_string(HEIGHTS).split("\n"))
	_trace_streams()
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if _land.kind(x, z) == _land.Kind.WALL and _land.is_front(x, z) and (_touches(x, z, "d") or _touches(x, z, "x")):
				# Em volta das áreas escuras, a parede da frente sobe até a tampa de escuridão.
				_land.set_wall_height(x, z, DARK_WALL_HEIGHT)
			elif _cell(x, z) == "V":
				# O elevador fica num rebaixo de 1 bloco: a plataforma quebrada, torta, entra nele sem cortar o chão.
				_land.force_top(x, z, _land.height(x, z) - 1)
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			_place_column(x, z)
	# Beiradas que sobram (desnível de 2 ou mais, sem rampa): pedras que seguram quem anda.
	for cell: Vector2i in _land.ledges():
		_terrain.set_cell_item(Vector3i(cell.x, _land.height(cell.x, cell.y), cell.y), _item("Rocha"))
	_decorate()
	_decorate_floor()
	_build_spores()
	_build_navigation()


func _grid(grid_name: String, layer: int) -> GridMap:
	var grid := GridMap.new()
	grid.name = grid_name
	grid.mesh_library = _library
	grid.cell_size = Vector3.ONE
	grid.collision_layer = layer
	_add(_root, grid)
	return grid


func _place_column(x: int, z: int) -> void:
	match _land.kind(x, z):
		_land.Kind.FLOOR:
			_floor(x, z)
			match _cell(x, z):
				"U":
					_giant_mushroom(x, z, _land.height(x, z), true)
				"u":
					var h: int = _land.height(x, z)
					_terrain.set_cell_item(Vector3i(x, h, z), _item("Chapéu ciano") if (x + z) % 2 == 0 else _item("Chapéu verde-limão"))
					_light(Vector3(x + 0.5, h + 1.2, z + 0.5), CYAN if (x + z) % 2 == 0 else LIME, 6.0, 1.5)
		_land.Kind.BRIDGE:
			# O pé de um cogumelo gigante caído atravessa a fenda.
			_land.place_bridge(_terrain, x, z, _item("Pé de cogumelo"), _item("Pé de cogumelo"), 3, _item("Água brilhante"), _item("Rocha funda"))
		_land.Kind.CHASM:
			_land.place_column(_terrain, x, z, _item("Água brilhante"), _item("Rocha funda"))
			_land.place_edge(_barriers, _decor, x, z, _item("Invisível"), _item("Cerca"))
		_:
			match _cell(x, z):
				"M":
					_land.place_column(_terrain, x, z, _item("Pedra do povo antigo"), _item("Pedra do povo antigo"), _item("Rocha funda"))
				"m", "3":
					_land.place_column(_terrain, x, z, _item("Lugar do mural"), _item("Lugar do mural"), _item("Rocha funda"))
				_:
					if _land.is_bottom(x, z):
						_land.place_column(_terrain, x, z, _item("Água brilhante"), _item("Rocha funda"), _item("Rocha funda"))
					else:
						# Manchas de musgo no alto da rocha, para os morros não serem uma massa só.
						var moss: bool = _land.kind(x, z) == _land.Kind.FILL and _land.chance(x, z, 12) < 0.35
						_land.place_column(_terrain, x, z, _item("Chão de musgo") if moss else _item("Rocha"), _item("Rocha"), _item("Rocha funda"))
			_land.place_sight(_sight, x, z, _item("Invisível"))


func _floor(x: int, z: int) -> void:
	var ch := _cell(x, z)
	if ch == "V":
		_land.place_column(_terrain, x, z, _item("Rocha funda"), _item("Rocha funda"))
		return
	# A borda entre o musgo e a terra fica misturada: o chão vem de um bloco vizinho puxado pelo ruído. O musgo e a
	# terra têm manchas (o musgo em três tons, a terra com cascalho), e o riacho corre num leito de pedrinhas.
	var zone: Vector2i = _land.blend_source(x, z)
	var top := _moss_patch(x, z) if _is_moss(zone.x, zone.y) else _dirt_patch(x, z)
	if _streams.has(Vector2i(x, z)):
		top = _item("Leito do riacho")
		_decor.set_cell_item(Vector3i(x, _land.height(x, z), z), _item("Riacho"))
	_land.place_floor(_terrain, x, z, top, _item("Chão de terra"), _item("Escada"))
	# Abaixo do chão, a beira das fendas é de rocha funda, como as paredes delas.
	for y in range(_land.bottom(x, z), _land.height(x, z) - 1):
		_terrain.set_cell_item(Vector3i(x, y, z), _item("Rocha funda"))


func _moss_patch(x: int, z: int) -> int:
	var patch: float = _land.smooth_noise(x, z, PATCH_SCALE, 31)
	if patch < 0.36:
		return _item("Musgo escuro")
	return _item("Musgo claro") if patch > 0.64 else _item("Chão de musgo")


func _dirt_patch(x: int, z: int) -> int:
	return _item("Cascalho do bosque") if _land.smooth_noise(x, z, GRAVEL_SCALE, 37) > 0.68 else _item("Chão de terra")


# Chão de musgo: o "," do rascunho, e os objetos encostados nele.
func _is_moss(x: int, z: int) -> bool:
	var ch := _cell(x, z)
	if ch == ",":
		return true
	if ch in [".", "d", "x"]:
		return false
	for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if _cell(x + side.x, z + side.y) == ",":
			return true
	return false


# Cogumelo gigante bioluminescente: pé de 3 blocos e chapéu de 3 × 3 que brilha, com uma luz embaixo (só nos do
# caminho: os de fora brilham pelo chapéu).
func _giant_mushroom(x: int, z: int, base: int, with_light: bool) -> void:
	_mushrooms += 1
	var cap := _item("Chapéu ciano") if _mushrooms % 2 == 0 else _item("Chapéu verde-limão")
	for y in range(base, base + STEM_HEIGHT):
		_terrain.set_cell_item(Vector3i(x, y, z), _item("Pé de cogumelo"))
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			_set_if_empty(Vector3i(x + dx, base + STEM_HEIGHT, z + dz), cap)
	_set_if_empty(Vector3i(x, base + STEM_HEIGHT + 1, z), cap)
	# Cipós pendurados debaixo da borda do chapéu, alguns mais compridos.
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			if (dx != 0 or dz != 0) and _land.chance(x + dx, z + dz, 47) < VINES:
				_decor_if_empty(Vector3i(x + dx, base + STEM_HEIGHT - 1, z + dz), _item("Cipó"))
				if _land.chance(x + dx, z + dz, 53) < LONG_VINES:
					_decor_if_empty(Vector3i(x + dx, base + STEM_HEIGHT - 2, z + dz), _item("Cipó"))
	if with_light:
		_light(Vector3(x + 0.5, base + STEM_HEIGHT - 0.4, z + 0.5), CYAN if cap == _item("Chapéu ciano") else LIME, 8.0, 2.0)


func _set_if_empty(where: Vector3i, item: int) -> void:
	if _terrain.get_cell_item(where) == GridMap.INVALID_CELL_ITEM:
		_terrain.set_cell_item(where, item)


# Os enfeites de fora: cogumelos gigantes nos morros, cogumelos pequenos acesos nos morros e no fundo das fendas, e
# luzes no fundo, perto do caminho.
func _decorate() -> void:
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			var kind: int = _land.kind(x, z)
			if kind != _land.Kind.FILL and kind != _land.Kind.CHASM:
				continue
			var top: int = _land.top(x, z)
			var roll: float = _land.chance(x, z, 11)
			if kind == _land.Kind.FILL and not _land.is_bottom(x, z) and top >= _land.base(x, z) + 2:
				if roll < 0.035 and top + STEM_HEIGHT + 2 <= _land.cap(x, z) and _clear_around(x, z, top):
					_giant_mushroom(x, z, top, false)
				elif roll < 0.12:
					_decor_if_empty(Vector3i(x, top, z), _small_mushroom(x, z))
				else:
					_decorate_hill(x, z, top, roll - 0.12)
			elif _land.is_bottom(x, z) or kind == _land.Kind.CHASM:
				if roll < 0.1:
					_decor_if_empty(Vector3i(x, top, z), _small_mushroom(x, z))
				if x % BOTTOM_LIGHT_EVERY == 0 and z % BOTTOM_LIGHT_EVERY == 0 and _land.distance(x, z) <= BOTTOM_LIGHT_REACH:
					_light(Vector3(x + 0.5, top + 1.5, z + 0.5), CYAN if (x / BOTTOM_LIGHT_EVERY) % 2 == 0 else LIME, 7.0, 1.6)


# O alto de um morro: arbustos, plantas, troncos caídos e restos de ruína com musgo, sem passar do teto da coluna (a
# linha de visão da câmera).
func _decorate_hill(x: int, z: int, top: int, roll: float) -> void:
	var room: int = _land.cap(x, z) - top
	if roll < HILL_BUSHES:
		if room >= 1:
			_set_if_empty(Vector3i(x, top, z), _item("Folhas do bosque"))
	elif roll < HILL_BUSHES + HILL_PLANTS:
		_decor_if_empty(Vector3i(x, top, z), _plant(x, z))
	elif roll < HILL_BUSHES + HILL_PLANTS + HILL_LOGS:
		_fallen_log(x, z, top)
	elif roll < HILL_BUSHES + HILL_PLANTS + HILL_LOGS + HILL_RUINS:
		for y in mini(1 + _land.noise(x, z) % 3, room):
			_set_if_empty(Vector3i(x, top + y, z), _item("Pedra antiga com musgo"))


# Tronco caído: alguns blocos de casca deitados em fila, para o lado em que cabem no alto do morro.
func _fallen_log(x: int, z: int, top: int) -> void:
	var along := Vector2i(1, 0) if _land.noise(x, z) % 2 == 0 else Vector2i(0, 1)
	for i in LOG_LENGTH:
		var spot := Vector2i(x, z) + along * i
		if _land.kind(spot.x, spot.y) != _land.Kind.FILL or _land.top(spot.x, spot.y) != top or _land.cap(spot.x, spot.y) <= top:
			return
	for i in LOG_LENGTH:
		var spot := Vector2i(x, z) + along * i
		_set_if_empty(Vector3i(spot.x, top, spot.y), _item("Tronco do bosque"))


# Uma planta do Bosque: capim, capim alto ou samambaia.
func _plant(x: int, z: int) -> int:
	var pick: float = _land.chance(x, z, 59)
	if pick < 0.3:
		return _item("Samambaia")
	return _item("Capim alto do bosque") if pick < 0.7 else _item("Capim do bosque")


# O chão de dentro: plantas perto das paredes, nas manchas de musgo e um pouco na terra, e as flores que brilham; longe
# dos objetos, das rampas e dos riachos (a planta não segura ninguém: é só enfeite).
func _decorate_floor() -> void:
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if not _free_floor(x, z) or _streams.has(Vector2i(x, z)):
				continue
			var where := Vector3i(x, _land.height(x, z), z)
			var roll: float = _land.chance(x, z, 41)
			var moss := _is_moss(x, z)
			if _near_stream(x, z) and roll < BANK_PLANTS:
				_decor_if_empty(where, _plant(x, z))
			elif _near_wall(x, z) and roll < EDGE_PLANTS:
				_decor_if_empty(where, _plant(x, z))
			elif moss and _land.smooth_noise(x, z, 3.5, 43) > 0.55 and roll < MOSS_PLANTS:
				_decor_if_empty(where, _item("Flor de luz") if roll < MOSS_PLANTS * 0.15 else _plant(x, z))
			elif moss and roll < GLOW_FLOWERS:
				_decor_if_empty(where, _item("Flor de luz"))
			elif not moss and roll < DIRT_PLANTS:
				_decor_if_empty(where, _item("Capim do bosque"))


# Chão comum e plano, sem objeto nele nem em volta (os objetos ficam legíveis).
func _free_floor(x: int, z: int) -> bool:
	if _land.kind(x, z) != _land.Kind.FLOOR or not _land.ramp_at(x, z).is_empty() or _land.stairs_at(x, z) != "":
		return false
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if _cell(x + dx, z + dz) not in [".", ",", "#", "~"]:
				return false
	return true


func _near_wall(x: int, z: int) -> bool:
	for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var kind: int = _land.kind(x + side.x, z + side.y)
		if kind == _land.Kind.WALL or kind == _land.Kind.FILL:
			return true
	return false


func _near_stream(x: int, z: int) -> bool:
	for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if _streams.has(Vector2i(x, z) + side):
			return true
	return false


# Os riachos: cada trecho entre dois pontos vira uma fila de blocos de chão livre, às vezes com 2 de largura.
func _trace_streams() -> void:
	for stream: Array in STREAMS:
		for i in stream.size() - 1:
			var from: Vector2i = stream[i]
			var to: Vector2i = stream[i + 1]
			var steps := maxi(absi(to.x - from.x), absi(to.y - from.y)) * 2
			var last := from
			for step in steps + 1:
				var cell := Vector2i(Vector2(from).lerp(Vector2(to), float(step) / steps).round())
				# Um passo na diagonal ganha o bloco do canto, para a água não pular de quina em quina.
				if cell.x != last.x and cell.y != last.y:
					_add_stream(Vector2i(cell.x, last.y))
				_add_stream(cell)
				if _land.smooth_noise(cell.x, cell.y, 3.0, 61) > STREAM_WIDE:
					_add_stream(cell + Vector2i(1, 0))
				last = cell


func _add_stream(cell: Vector2i) -> void:
	if _free_floor(cell.x, cell.y):
		_streams[cell] = true


# Esporos que brilham flutuando no ar, um grupo a cada tantos blocos de chão (data/effects/forest_spores.tres).
func _build_spores() -> void:
	var layer := load("res://data/effects/forest_spores.tres") as ParticleLayer
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if x % SPORES_EVERY != 0 or z % SPORES_EVERY != 0 or _land.kind(x, z) != _land.Kind.FLOOR:
				continue
			var spores := layer.build(Vector3.ONE)
			spores.name = "Spores"
			spores.position += Vector3(x + 0.5, _land.height(x, z), z + 0.5)
			# Já no ar quando a área abre.
			spores.preprocess = layer.lifetime
			_add(_root, spores)


func _small_mushroom(x: int, z: int) -> int:
	return _item("Cogumelo ciano") if _land.noise(x, z) % 2 == 0 else _item("Cogumelo verde-limão")


# Cogumelo gigante só com espaço em volta: o chapéu não encosta em outro.
func _clear_around(x: int, z: int, top: int) -> bool:
	for dz in range(-2, 3):
		for dx in range(-2, 3):
			if _terrain.get_cell_item(Vector3i(x + dx, top + STEM_HEIGHT, z + dz)) != GridMap.INVALID_CELL_ITEM:
				return false
			if _land.top(x + dx, z + dz) > top:
				return false
	return true


func _decor_if_empty(where: Vector3i, item: int) -> void:
	if _decor.get_cell_item(where) == GridMap.INVALID_CELL_ITEM and _terrain.get_cell_item(where) == GridMap.INVALID_CELL_ITEM:
		_decor.set_cell_item(where, item)


func _light(where: Vector3, color: Color, light_range: float, energy: float) -> void:
	var light := OmniLight3D.new()
	light.name = "FungusLight"
	light.position = where
	light.light_color = color
	light.omni_range = light_range
	light.light_energy = energy
	_add(_root, light)


func _touches(x: int, z: int, ch: String) -> bool:
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if _cell(x + dx, z + dz) == ch:
				return true
	return false


# O mapa de navegação dos mobs, assado do terreno e guardado ao lado da área.
func _build_navigation() -> void:
	var navigation: NavigationMesh = _land.bake_navigation(_terrain)
	print(NAVIGATION_PATH, ": ", error_string(ResourceSaver.save(navigation, NAVIGATION_PATH)), " (", navigation.get_polygon_count(), " polígonos)")
	var region := NavigationRegion3D.new()
	region.name = "Navigation"
	region.navigation_mesh = load(NAVIGATION_PATH)
	_add(_root, region)
	print("blocos: terreno %d, visão %d, barreiras %d, enfeites %d" % [_terrain.get_used_cells().size(),
		_sight.get_used_cells().size(), _barriers.get_used_cells().size(), _decor.get_used_cells().size()])


func _build_player() -> Node3D:
	var player: Node3D = (load("res://player/player.tscn") as PackedScene).instantiate()
	_add(_root, player)
	_root.set("player", player)
	var camera: Camera3D = (load("res://world/follow_camera.gd") as GDScript).new()
	camera.name = "FollowCamera"
	camera.target = player
	_add(_root, camera)
	return player


func _build_objects() -> void:
	_objects = Node3D.new()
	_objects.name = "Objects"
	_add(_root, _objects)
	var mobs := Node3D.new()
	mobs.name = "Mobs"
	_add(_root, mobs)
	var seen := {}
	var gates := {}
	var spawns := {"o": [], "p": [], "q": []}
	var exit_cells: Array[Vector2i] = []
	for z in _rows.size():
		for x in _rows[z].length():
			var ch := _cell(x, z)
			match ch:
				"1", "2":
					var sanctuary := _instance(_objects, "res://world/objects/sanctuary.tscn", _center(x, z), 0.0)
					sanctuary.name = "Sanctuary" + ch
					sanctuary.set("save_id", StringName("s" + ch))
					sanctuary.set("data", load("res://data/sanctuaries/s%s.tres" % ch))
					sanctuary.set("gives_flask", ch == "1")
				"V":
					if not seen.has("V"):
						seen["V"] = true
						_build_elevator(x, z)
				"C":
					var chest := _instance(_objects, "res://world/objects/chest.tscn", _center(x, z), PI)
					chest.set("save_id", &"forest_chest_spear")
					chest.set("item_id", &"spear")
				"F", "A":
					var scroll := _instance(_objects, "res://world/objects/scroll.tscn", _center(x, z), 0.0)
					var element := &"fire" if ch == "F" else &"water"
					scroll.name = "Scroll" + String(element).capitalize()
					scroll.set("save_id", StringName("forest_scroll_" + element))
					scroll.set("element_id", element)
				"h", "H", "z", "j", "c":
					var upgrade := _instance(_objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					upgrade.set("save_id", UPGRADES[ch][0])
					upgrade.set("item_id", UPGRADES[ch][1])
					upgrade.set("upgrade", true)
				"W":
					_mob(mobs, "res://mobs/wolf.tscn", "forest_wolf", _center(x, z))
				"K":
					_mob(mobs, "res://mobs/skeleton.tscn", "forest_skeleton", _center(x, z))
				"N":
					_mob(mobs, "res://mobs/necromancer.tscn", "forest_necromancer", _center(x, z))
				"s":
					_instance(_objects, "res://world/traps/spore_mushroom.tscn", _center(x, z), 0.0)
				"m", "3":
					# O mural na frente da parede norte, virado para o sul (08-mapa).
					var mural := _instance(_objects, "res://world/objects/mural.tscn", Vector3(x + 0.5, _ground(x, z + 1), z + 1.05), PI)
					mural.name = "Mural2" if ch == "m" else "Mural3"
					mural.set("mural_id", 2 if ch == "m" else 3)
				"X":
					var wall := _instance(_objects, "res://world/objects/cracked_wall.tscn", _center(x, z), 0.0)
					wall.set("save_id", &"forest_cracked_wall_1")
					wall.set("size", Vector3(1, CRACKED_HEIGHT, 1))
					wall.set("material", (_library.get_item_mesh(_item("Parede rachada")) as BoxMesh).material)
				"a", "b", "e", "f", "g", "k":
					gates.get_or_add(ch, []).append(Vector2i(x, z))
				"o", "p", "q":
					var spot := Marker3D.new()
					spot.name = "ArenaSpawn"
					spot.position = _center(x, z)
					spot.rotation.y = PI
					_add(_objects, spot)
					spawns[ch].append(spot)
				"x":
					exit_cells.append(Vector2i(x, z))
	_build_door()
	_build_arena("ForestArena1", &"forest_arena_1", gates["a"], gates["b"], spawns["o"], ["forest_1_wave_1", "forest_1_wave_2"])
	_build_arena("ForestArena2", &"forest_arena_2", gates["e"], gates["f"], spawns["p"], ["forest_2_wave_1", "forest_2_wave_2", "forest_2_wave_3"])
	_build_arena("ForestArenaOptional", &"forest_arena_optional", gates["g"], gates["k"], spawns["q"], ["forest_optional_wave_1", "forest_optional_wave_2"])
	_build_exit(exit_cells)


# O elevador quebrado ao lado do S1: Nate chega nele vindo da Mina e, consertado, sobe de volta (08-mapa).
func _build_elevator(x: int, z: int) -> void:
	var elevator := _instance(_objects, "res://world/objects/elevator.tscn", Vector3(x + 1.5, _ground(x, z), z + 1.5), 0.0)
	elevator.set("save_id", &"forest_elevator")
	elevator.set("destination", "res://world/areas/mine.tscn")
	elevator.set("destination_arrival", &"mine_elevator")
	elevator.set("arrival_id", &"forest_elevator")
	elevator.set("travel_direction", 1)
	elevator.set("repair_id", &"elevator_repaired")
	elevator.set("needs_repair", true)
	_root.set("start_point", elevator.get_node(^"Arrival"))


# A porta que só abre por um lado, na parede leste do S1: a frente (o lado de dentro) fica para o corredor.
func _build_door() -> void:
	var cells: Array[Vector2i] = []
	for z in _rows.size():
		for x in _rows[z].length():
			if _cell(x, z) == "D":
				cells.append(Vector2i(x, z))
	var center := Vector2.ZERO
	for cell in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var door := _instance(_objects, "res://world/objects/one_way_door.tscn", Vector3(center.x, _ground(center.x, center.y), center.y), -PI / 2.0)
	door.set("save_id", &"forest_shortcut_door")


func _build_arena(node_name: String, save_id: StringName, entry: Array, exit_cells: Array, spawns: Array, waves: Array) -> void:
	var entry_gate := _gate(entry)
	var exit_gate := _gate(exit_cells)
	entry_gate.set("starts_open", true)
	exit_gate.set("starts_open", false)
	# O chão da arena: o retângulo entre os pontos de surgir, com 2 blocos de folga.
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for spot: Marker3D in spawns:
		low = low.min(Vector2(spot.position.x, spot.position.z))
		high = high.max(Vector2(spot.position.x, spot.position.z))
	var arena: Node3D = (load("res://world/arena.gd") as GDScript).new()
	arena.name = node_name
	arena.position = Vector3((low.x + high.x) / 2.0, _ground(low.x, low.y), (low.y + high.y) / 2.0)
	arena.set("save_id", save_id)
	arena.set("area_size", high - low + Vector2(2, 2))
	var wave_data := []
	for wave_name: String in waves:
		wave_data.append(load("res://data/arenas/%s.tres" % wave_name))
	arena.set("waves", _typed(wave_data, &"Resource", "res://world/arena_wave.gd"))
	arena.set("gates", _typed([entry_gate, exit_gate], &"StaticBody3D", "res://world/objects/gate.gd"))
	arena.set("spawn_points", Array(spawns, TYPE_OBJECT, &"Node3D", null))
	_add(_objects, arena)


# Portão no meio das células marcadas, virado para atravessar a passagem.
func _gate(cells: Array) -> Node3D:
	var center := Vector2.ZERO
	for cell: Vector2i in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var along_z: bool = cells.size() > 1 and cells[0].x == cells[1].x
	return _instance(_objects, "res://world/objects/gate_%d.tscn" % cells.size(), Vector3(center.x, _ground(center.x, center.y), center.y), PI / 2.0 if along_z else 0.0)


# Fim da passagem escura: até as Ruínas existirem, a parte jogável termina aqui.
func _build_exit(cells: Array[Vector2i]) -> void:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	var exit: Node3D = (load("res://world/area_exit.gd") as GDScript).new()
	exit.name = "AreaExit"
	exit.position = Vector3((low.x + high.x) / 2.0 + 0.5, _ground(low.x, low.y), (low.y + high.y) / 2.0 + 0.5)
	exit.set("area_size", high - low + Vector2.ONE)
	# A passagem escura leva às Ruínas (08-mapa).
	exit.set("next_area", "res://world/areas/ruins.tscn")
	exit.set("arrival", &"ruins_entrance")
	_add(_objects, exit)
	_root.set("exit", exit)


# Áreas escuras (08-mapa): cada mancha de chão escuro vira um retângulo com a tampa de escuridão e a barreira.
func _build_dark_areas() -> void:
	var done := {}
	for z in _rows.size():
		for x in _rows[z].length():
			if _cell(x, z) not in ["d", "x"] or done.has(Vector2i(x, z)):
				continue
			var low := Vector2i(x, z)
			var high := Vector2i(x, z)
			var queue: Array[Vector2i] = [Vector2i(x, z)]
			var region: Array[Vector2i] = []
			done[Vector2i(x, z)] = true
			while not queue.is_empty():
				var cell: Vector2i = queue.pop_back()
				region.append(cell)
				low = low.min(cell)
				high = high.max(cell)
				for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var next := cell + side
					if _cell(next.x, next.y) in ["d", "x"] and not done.has(next):
						done[next] = true
						queue.append(next)
			var dark: Node3D = (load("res://world/dark_area.gd") as GDScript).new()
			dark.name = "DarkArea"
			dark.position = Vector3((low.x + high.x + 1) / 2.0, _ground(x, z), (low.y + high.y + 1) / 2.0)
			dark.set("area_size", Vector2(high - low + Vector2i.ONE))
			dark.set("cover_height", DARK_WALL_HEIGHT + 0.05)
			dark.set("mask", _dark_mask(region, low, high))
			dark.set("margin", 1.0)
			dark.set("darkness", 0.9)
			dark.set("edge_resolution", 8)
			dark.set("wobble_size", 1.5)
			dark.set("wobble", 0.35)
			dark.set("edge_start", 0.2)
			dark.set("edge_end", 0.8)
			_add(_objects, dark)


func _mob(parent: Node3D, scene_path: String, id_prefix: String, where: Vector3) -> Node3D:
	var mob := _instance(parent, scene_path, where, PI)
	mob.set("save_id", _next_id(id_prefix))
	return mob


func _instance(parent: Node3D, scene_path: String, where: Vector3, facing: float) -> Node3D:
	var node := (load(scene_path) as PackedScene).instantiate() as Node3D
	node.position = where
	node.rotation.y = facing
	_add(parent, node)
	return node


func _next_id(prefix: String) -> StringName:
	_counts[prefix] = _counts.get(prefix, 0) + 1
	return StringName("%s_%d" % [prefix, _counts[prefix]])


func _build_interface(player: Node3D) -> void:
	_add(_root, (load("res://ui/hud.tscn") as PackedScene).instantiate())
	var hint_layer := CanvasLayer.new()
	hint_layer.name = "HintLayer"
	_add(_root, hint_layer)
	var hints: VBoxContainer = (load("res://ui/control_hints.gd") as GDScript).new()
	hints.name = "ControlHints"
	hints.target = player
	hints.height = 2.4
	hints.alignment = BoxContainer.ALIGNMENT_END
	_add(hint_layer, hints)
	var director: Node = (load("res://ui/hint_director.gd") as GDScript).new()
	director.name = "HintDirector"
	var item_hints := Dictionary({
		&"slingshot": load("res://data/ui/hint_shoot.tres"),
		&"flask": load("res://data/ui/hint_flask.tres"),
		&"fire": load("res://data/ui/hint_spell.tres"),
		&"water": load("res://data/ui/hint_combo.tres"),
		&"earth": load("res://data/ui/hint_combo.tres"),
		&"spear": load("res://data/ui/hint_inventory.tres"),
	}, TYPE_STRING_NAME, &"", null, TYPE_OBJECT, &"Resource", load("res://ui/hint_data.gd"))
	director.set("item_hints", item_hints)
	director.set("interact_hint", load("res://data/ui/hint_interact.tres"))
	director.set("mural_hint", load("res://data/ui/hint_murals.tres"))
	director.set("hints", hints)
	director.set("hint_scene", load("res://ui/button_hint.tscn"))
	_add(_root, director)
	var end_layer := CanvasLayer.new()
	end_layer.name = "EndLayer"
	end_layer.layer = 5
	_add(_root, end_layer)
	var end: Control = (load("res://ui/end_screen.tscn") as PackedScene).instantiate()
	_add(end_layer, end)
	_root.set("end_screen", end)
	_add(_root, (load("res://ui/pause_menu.tscn") as PackedScene).instantiate())
	_add(_root, (load("res://ui/inventory.tscn") as PackedScene).instantiate())
	_add(_root, (load("res://ui/mural_gallery.tscn") as PackedScene).instantiate())


# Lista tipada com um script carregado só agora: os tipos que dependem dos sistemas globais não compilam antes.
func _typed(items: Array, base: StringName, script_path: String) -> Array:
	return Array(items, TYPE_OBJECT, base, load(script_path))


func _add(parent: Node, node: Node) -> void:
	parent.add_child(node, true)
	node.owner = _root


# A forma da área escura: um ponto por bloco (branco no escuro), com 1 bloco de margem em volta.
func _dark_mask(region: Array[Vector2i], low: Vector2i, high: Vector2i) -> ImageTexture:
	var image := Image.create_empty(high.x - low.x + 3, high.y - low.y + 3, false, Image.FORMAT_L8)
	for cell in region:
		image.set_pixel(cell.x - low.x + 1, cell.y - low.y + 1, Color.WHITE)
	return ImageTexture.create_from_image(image)
