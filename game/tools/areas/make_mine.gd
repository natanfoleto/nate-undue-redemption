extends SceneTree
# Monta a área do prólogo e da Mina (world/areas/mine.tscn) a partir dos rascunhos em texto (mine_layout.txt e
# mine_heights.txt; o montador do terreno explica o formato). Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_mine.gd
#
# Em volta da clareira, o mundo de fora (08-mapa): mata subindo em morros a oeste, a vila abandonada dos mineiros
# num terraço mais baixo a leste e, ao sul, a encosta que desce até o rio Nhamundá, com a cidade do outro lado.
# Embaixo da terra, rocha em volta das galerias e, na frente da câmera, galerias inundadas de água escura.

const FOLDER := "res://tools/areas/"
const LAYOUT := FOLDER + "mine_layout.txt"
const HEIGHTS := FOLDER + "mine_heights.txt"
const BUILDER := FOLDER + "terrain_builder.gd"
const NAVIGATION_PATH := "res://world/areas/mine_navigation.res"
const AREA_PATH := "res://world/areas/mine.tscn"

# Caracteres do rascunho que são chão (onde se anda ou onde fica um objeto em cima do chão). A vala e a galeria
# inundada (~) são abismos.
const FLOOR_CHARS := ".wgfVaGEFbpCWKorPSdhyijquXL"

# A clareira começa nesta linha; acima dela é a Mina.
const SURFACE_Z := 92
# O rio Nhamundá corre de leste a oeste ao sul da clareira, entre estas linhas; a cidade fica do outro lado.
const RIVER_NORTH := 132
const RIVER_SOUTH := 136
const TOWN_Z := 139
# O terraço da vila dos mineiros, a leste da clareira, e as casas dela: canto, largura e fundo, em blocos.
const VILLAGE_X := 48
const SHACKS := [[49, 98, 4, 3], [55, 99, 4, 4], [50, 106, 3, 4], [57, 108, 4, 3], [52, 114, 4, 3]]

var _rows: PackedStringArray
var _root: Node3D
var _library: MeshLibrary
var _terrain: GridMap
var _barriers: GridMap
var _sight: GridMap
var _decor: GridMap
var _land: RefCounted
var _patches := FastNoiseLite.new()
var _items := {}
var _counts := {}


func _initialize() -> void:
	_rows = FileAccess.get_file_as_string(LAYOUT).split("\n")
	_root = (load("res://world/area_level.gd") as GDScript).new()
	_root.name = "Mine"
	# Música da clareira e da Mina; as gotas e o vento tocam só lá dentro (a zona de luz troca o som de fundo).
	_root.set("music", load("res://assets/audio/music/krakatoa.ogg"))
	_build_lighting()
	_build_terrain()
	var player := _build_player()
	_build_objects(player)
	_build_interface(player)
	var scene := PackedScene.new()
	scene.pack(_root)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://world/areas"))
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


func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("101114")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.66, 0.72)
	environment.ambient_light_energy = 0.7
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	world.environment = environment
	_add(_root, world)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-55, 130, 0)
	sun.light_color = Color(1, 0.95, 0.85)
	sun.shadow_enabled = true
	_add(_root, sun)
	# Embaixo da terra, o sol some e a luz vem dos lampiões (10-arte-audio).
	var zone: Node3D = (load("res://world/lighting_zone.gd") as GDScript).new()
	zone.name = "MineLighting"
	zone.position = Vector3(32, 0, SURFACE_Z / 2.0)
	zone.set("sun", sun)
	zone.set("world", world)
	zone.set("area_size", Vector2(64, SURFACE_Z))
	zone.set("inside_sun_energy", 0.0)
	zone.set("inside_ambient_energy", 0.3)
	zone.set("change_time", 1.5)
	zone.set("inside_ambience", load("res://assets/audio/ambience/dungeon_ambient_1.ogg"))
	_add(_root, zone)


func _build_terrain() -> void:
	_library = load("res://world/blocks/mine_blocks.tres")
	_terrain = _grid("Terrain", HitShape.WORLD_LAYER)
	# Blocos invisíveis em cima das paredes baixas: seguram os tiros e a visão, como as outras paredes.
	_sight = _grid("Sight", HitShape.WORLD_LAYER)
	# Barreiras invisíveis na beira dos abismos: seguram quem anda, mas não os tiros nem a visão.
	_barriers = _grid("Barriers", HitShape.BARRIER_LAYER)
	# Enfeites sem colisão: cercas, capim, flores e trilhos.
	_decor = _grid("Decor", 0)
	_land = (load(BUILDER) as GDScript).new()
	_land.floor_chars = FLOOR_CHARS
	_land.auto_ramps = true
	_land.slope_chars = ".wg"
	_land.setup(_rows, FileAccess.get_file_as_string(HEIGHTS).split("\n"))
	_patches.seed = 7
	_patches.frequency = 0.12
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if _land.kind(x, z) == _land.Kind.WALL and _land.is_front(x, z) and (_cell(x, z) == "M" or _touches(x, z, "d")):
				# Atrás do mural e em volta da área escura, a parede da frente sobe até a tampa de escuridão.
				_land.set_wall_height(x, z, 2)
	_shape_outside()
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			_place_column(x, z)
	_decorate()
	# Beiradas que sobram (desnível de 2 ou mais, sem rampa): moitas que seguram quem anda.
	for cell: Vector2i in _land.ledges():
		_terrain.set_cell_item(Vector3i(cell.x, _land.height(cell.x, cell.y), cell.y), _item("Folhas"))
	_build_navigation()


func _grid(grid_name: String, layer: int) -> GridMap:
	var grid := GridMap.new()
	grid.name = grid_name
	grid.mesh_library = _library
	grid.cell_size = Vector3.ONE
	grid.collision_layer = layer
	_add(_root, grid)
	return grid


func _is_surface(z: int) -> bool:
	return z >= SURFACE_Z


# O relevo de fora e as colunas especiais do rascunho: o paredão, a mata da borda e os postes dos lampiões.
func _shape_outside() -> void:
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			var kind: int = _land.kind(x, z)
			if kind != _land.Kind.WALL and kind != _land.Kind.FILL:
				continue
			match _cell(x, z):
				"R", "m":
					_land.set_top(x, z, _cliff_top(x, z))
				"T":
					_land.force_top(x, z, _land.ground(x, z))
				"l":
					_land.force_top(x, z, _land.ground(x, z) + 2)
				_:
					if _is_surface(z):
						_land.set_top(x, z, _outside_top(x, z))


# O paredão entre a clareira e a mina: alto e irregular de frente para a clareira, baixando para o lado da mina
# (para não esconder a entrada dela) e baixo do lado da câmera no caminho; sempre acima do chão mais perto.
func _cliff_top(x: int, z: int) -> int:
	var base: int = _land.base(x, z)
	if _land.is_front(x, z):
		return base + 1
	return base + maxi(mini(3 + _land.noise(x, z) % 3, z - SURFACE_Z + 1), 1)


# O chão de fora: morros com mata a oeste, o terraço da vila a leste e a encosta do rio ao sul.
func _outside_top(x: int, z: int) -> int:
	if z >= RIVER_NORTH and z <= RIVER_SOUTH:
		return -4
	if z == RIVER_NORTH - 1 or z == RIVER_SOUTH + 1:
		return -4
	if z > RIVER_SOUTH:
		return -3 + mini((z - RIVER_SOUTH) / 8, 1)
	# As divisas dos morros, do terraço e da encosta ondulam com um ruído suave, sem linha reta.
	var wavy_x: float = x + (_land.smooth_noise(x, z, 7.0, 21) - 0.5) * 8.0
	var wavy_z: float = z + (_land.smooth_noise(x, z, 7.0, 22) - 0.5) * 6.0
	var hills := clampf((10.0 - wavy_x) * 0.55, 0.0, 7.0) + float(_land.noise(x, z) % 2) * minf(1.0, maxf(10.0 - wavy_x, 0.0))
	hills += roundf((_land.smooth_noise(x, z, 5.0, 23) - 0.5) * 2.0) * minf(1.0, maxf(12.0 - wavy_x, 0.0))
	var east := clampf((wavy_x - 45.0) * 0.7, 0.0, 2.0)
	var south := clampf((wavy_z - 125.0) * 0.6, 0.0, 3.0)
	return roundi(hills - maxf(east, south))


func _is_river(x: int, z: int) -> bool:
	return _is_surface(z) and z >= RIVER_NORTH and z <= RIVER_SOUTH and _land.kind(x, z) == _land.Kind.FILL


func _is_bank(x: int, z: int) -> bool:
	return _is_surface(z) and (z == RIVER_NORTH - 1 or z == RIVER_SOUTH + 1) and _land.kind(x, z) == _land.Kind.FILL


func _place_column(x: int, z: int) -> void:
	var surface := _is_surface(z)
	match _land.kind(x, z):
		_land.Kind.FLOOR:
			var ch := _cell(x, z)
			if ch == "V":
				# O poço do elevador: a plataforma segura Nate.
				return
			# A borda entre dois chões (a grama e a terra da fenda, as tábuas e a terra) fica misturada: o chão vem de um
			# bloco vizinho puxado pelo ruído.
			var zone: Vector2i = _land.blend_source(x, z)
			if _cell(zone.x, zone.y) == "V":
				zone = Vector2i(x, z)
			var top_item := _grass(x, z) if _is_surface(zone.y) else (_item("Tábuas") if _cell(zone.x, zone.y) == "w" else _dirt(x, z))
			_land.place_floor(_terrain, x, z, top_item, _item("Chão de terra"), _item("Escada"))
			if not surface:
				# Abaixo do chão, a beira das galerias inundadas é de rocha funda, como as paredes delas.
				for y in range(_land.bottom(x, z), _land.base(x, z) - 1):
					_terrain.set_cell_item(Vector3i(x, y, z), _item("Rocha funda"))
		_land.Kind.BRIDGE:
			_land.place_bridge(_terrain, x, z, _item("Tábuas"), _item("Tronco"), 2, _item("Água escura"), _item("Rocha funda"))
		_land.Kind.CHASM:
			_land.place_column(_terrain, x, z, _item("Água escura"), _item("Rocha funda"))
			_land.place_edge(_barriers, _decor, x, z, _item("Invisível"), _item("Cerca"))
		_:
			_place_rock(x, z, surface)
			_land.place_sight(_sight, x, z, _item("Invisível"))


func _place_rock(x: int, z: int, surface: bool) -> void:
	match _cell(x, z):
		"M":
			_land.place_column(_terrain, x, z, _item("Pedra do povo antigo"), _item("Pedra do povo antigo"))
			return
		"R":
			var cliff_grass: bool = _land.top(x, z) > 1
			_land.place_column(_terrain, x, z, _grass(x, z) if cliff_grass else _item("Rocha"), _item("Rocha"))
			return
		"m":
			_land.place_column(_terrain, x, z, _item("Tábuas"), _item("Tábuas"))
			return
		"T":
			_land.place_column(_terrain, x, z, _grass(x, z), _item("Chão de terra"))
			return
		"l":
			_land.place_column(_terrain, x, z, _item("Tronco"), _item("Rocha da mina"))
			_terrain.set_cell_item(Vector3i(x, _land.top(x, z) - 2, z), _item("Tronco"))
			return
	if surface:
		if _is_river(x, z):
			_land.place_column(_terrain, x, z, _item("Rio"), _item("Areia"))
		elif _is_bank(x, z):
			_land.place_column(_terrain, x, z, _item("Areia"), _item("Chão de terra"))
		else:
			_land.place_column(_terrain, x, z, _grass(x, z), _item("Chão de terra"))
		return
	if _land.is_bottom(x, z):
		_land.place_column(_terrain, x, z, _item("Água escura"), _item("Rocha funda"), _item("Rocha funda"))
	else:
		var top_item := _item("Rocha") if _patches.get_noise_2d(x - 300, z) > 0.35 else _item("Rocha da mina")
		_land.place_column(_terrain, x, z, top_item, _item("Rocha da mina"), _item("Rocha funda"))


# O chão da mina em manchas de terra, terra escura e cascalho.
func _dirt(x: int, z: int) -> int:
	var value := _patches.get_noise_2d(x + 500, z)
	return _item("Cascalho") if value > 0.3 else _item("Terra escura") if value < -0.3 else _item("Chão de terra")


# A grama em manchas de três tons, para o campo não ficar chapado.
func _grass(x: int, z: int) -> int:
	var value := _patches.get_noise_2d(x, z)
	return _item("Grama clara") if value > 0.25 else _item("Grama escura") if value < -0.25 else _item("Grama")


# Os enfeites, depois do terreno: a mata da borda e de fora, a vila, a cidade, as plantas e os esteios da mina.
func _decorate() -> void:
	_build_village()
	_build_town()
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			var kind: int = _land.kind(x, z)
			if _cell(x, z) == "T":
				_edge_tree(x, z)
			elif kind == _land.Kind.FLOOR and _cell(x, z) == "g":
				_clearing_plant(x, z)
			elif kind == _land.Kind.FILL and _is_surface(z):
				_outside_plant(x, z)
			elif kind == _land.Kind.FILL and _land.is_bottom(x, z):
				_mine_post(x, z)


# Borda da clareira: atrás (oeste), árvores e moitas altas; na frente da câmera (leste e sul), moitas baixas; no
# meio da clareira, árvore solta.
func _edge_tree(x: int, z: int) -> void:
	var base: int = _land.top(x, z)
	if _is_lone_tree(x, z):
		_tree(x, z, base, 3, false)
	elif _land.side(x, z) > 0.2:
		_set_if_empty(Vector3i(x, base, z), _item("Folhas"))
	elif (x + z) % 2 == 0:
		_tree(x, z, base, 2 + _land.noise(x, z) % 3, false)
	else:
		for y in range(base, base + 2):
			_set_if_empty(Vector3i(x, y, z), _item("Folhas da mata"))


# Árvore: tronco e copa (pequena, de 3 × 3, ou grande, de 5 × 5 com os cantos cortados). A copa não apaga troncos
# já postos nem passa do teto da visão.
func _tree(x: int, z: int, base: int, trunk: int, big: bool) -> void:
	if base + trunk + (3 if big else 2) > _land.cap(x, z):
		return
	for y in range(base, base + trunk):
		_terrain.set_cell_item(Vector3i(x, y, z), _item("Tronco"))
	var leaves := _item("Folhas") if _land.noise(x, z) % 3 != 0 else _item("Folhas da mata")
	var radius := 2 if big else 1
	for layer in (3 if big else 2):
		var y := base + trunk - (1 if big else 0) + layer
		var reach := radius if layer < 2 else radius - 1
		for dx in range(-reach, reach + 1):
			for dz in range(-reach, reach + 1):
				if big and absi(dx) == reach and absi(dz) == reach:
					continue
				if not big and layer == 1 and absi(dx) + absi(dz) == 2:
					continue
				if y + 1 <= _land.cap(x + dx, z + dz):
					_set_if_empty(Vector3i(x + dx, y, z + dz), leaves)


func _set_if_empty(where: Vector3i, item: int) -> void:
	if _terrain.get_cell_item(where) == GridMap.INVALID_CELL_ITEM:
		_terrain.set_cell_item(where, item)


func _decor_if_empty(where: Vector3i, item: int) -> void:
	if _decor.get_cell_item(where) == GridMap.INVALID_CELL_ITEM and _terrain.get_cell_item(where) == GridMap.INVALID_CELL_ITEM:
		_decor.set_cell_item(where, item)


# Árvore solta no meio da clareira: tronco e copa. As da borda viram mata.
func _is_lone_tree(x: int, z: int) -> bool:
	var grass := 0
	for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if _cell(x + side.x, z + side.y) == "g":
			grass += 1
	return grass >= 3


# Capim e flores espalhados pela clareira, sem colisão; longe dos degraus e dos pontos dos objetos.
func _clearing_plant(x: int, z: int) -> void:
	if _land.stairs_at(x, z) != "" or not _land.ramp_at(x, z).is_empty() or _land.chance(x, z, 2) > 0.06:
		return
	var plants := ["Capim", "Capim", "Capim alto", "Flor amarela", "Flor azul"]
	_decor_if_empty(Vector3i(x, _land.top(x, z), z), _item(plants[_land.noise(x, z) % plants.size()]))


# A mata de fora: árvores grandes e pequenas, mais fechada nos morros; no chão, capim, flores e, na beira do rio,
# papiro.
func _outside_plant(x: int, z: int) -> void:
	if _is_river(x, z):
		return
	var base: int = _land.top(x, z)
	if _terrain.get_cell_item(Vector3i(x, base, z)) != GridMap.INVALID_CELL_ITEM or _in_village(x, z) or z >= TOWN_Z - 1:
		return
	if _is_bank(x, z):
		if _land.chance(x, z, 3) < 0.5:
			_decor_if_empty(Vector3i(x, base, z), _item("Papiro"))
		return
	# Mata fechada nos morros; mais aberta no terraço da vila, para os barracos aparecerem.
	var density := 0.32 if x < 10 else 0.06 if x >= VILLAGE_X - 2 and z < RIVER_NORTH else 0.14
	var roll: float = _land.chance(x, z, 4)
	if roll < density and _room_for_tree(x, z, base):
		_tree(x, z, base, 3 + _land.noise(x, z) % 3, _land.chance(x, z, 5) < 0.35)
	elif roll < density + 0.3:
		var plants := ["Capim", "Capim alto", "Capim da mata", "Capim", "Flor vermelha", "Flor amarela", "Flor azul"]
		_decor_if_empty(Vector3i(x, base, z), _item(plants[_land.noise(x, z) % plants.size()]))


# Árvore só onde o tronco não encosta em outro, para a mata não virar um bloco só.
func _room_for_tree(x: int, z: int, base: int) -> bool:
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if _terrain.get_cell_item(Vector3i(x + dx, base, z + dz)) == _item("Tronco"):
				return false
	return true


func _in_village(x: int, z: int) -> bool:
	for shack: Array in SHACKS:
		if x >= shack[0] - 2 and x <= shack[0] + shack[2] + 1 and z >= shack[1] - 2 and z <= shack[1] + shack[3] + 1:
			return true
	return false


# A vila abandonada dos mineiros, no terraço a leste: barracos de madeira velha com o telhado caindo, um trilho e
# uma vagoneta.
func _build_village() -> void:
	for shack: Array in SHACKS:
		_shack(shack[0], shack[1], shack[2], shack[3])
	var rail_z := 104
	for x in range(VILLAGE_X - 1, VILLAGE_X + 15):
		if _land.kind(x, rail_z) == _land.Kind.FILL and not _in_village(x, rail_z):
			_decor.set_cell_item(Vector3i(x, _land.top(x, rail_z), rail_z), _item("Trilho"),
				_decor.get_orthogonal_index_from_basis(Basis(Vector3.UP, PI / 2.0)))
	_set_if_empty(Vector3i(VILLAGE_X + 6, _land.top(VILLAGE_X + 6, rail_z), rail_z), _item("Madeira velha"))


func _shack(x0: int, z0: int, width: int, depth: int) -> void:
	var base: int = _land.top(x0, z0)
	for z in range(z0, z0 + depth):
		for x in range(x0, x0 + width):
			_terrain.set_cell_item(Vector3i(x, base - 1, z), _item("Tábuas"))
			var wall := x == x0 or x == x0 + width - 1 or z == z0 or z == z0 + depth - 1
			var door := x == x0 and z == z0 + depth / 2
			for y in range(base, base + 3):
				var window := y == base + 1 and (z == z0 or z == z0 + depth - 1) and x == x0 + width / 2
				if wall and not door and not window and y + 1 <= _land.cap(x, z):
					_terrain.set_cell_item(Vector3i(x, y, z), _item("Madeira velha"))
			# Abandonado: parte do telhado já caiu.
			if _land.chance(x, z, 6) > 0.3 and base + 4 <= _land.cap(x, z):
				_terrain.set_cell_item(Vector3i(x, base + 3, z), _item("Tábuas"))


# Nhamundá do outro lado do rio: casas de madeira pintada com telhado de telha, algumas sobre palafitas na beira da
# água, árvores entre elas e canoas no rio.
func _build_town() -> void:
	var colors := ["Madeira azul", "Madeira amarela", "Madeira verde", "Madeira branca"]
	var index := 0
	for x0 in range(_land.low.x + 2, _land.high.x - 5, 7):
		var z0: int = TOWN_Z + (_land.noise(x0, 0) % 3)
		_house(x0, z0, 4, 4, colors[index % colors.size()])
		if _land.noise(x0, 1) % 2 == 0:
			_house(x0 + 1, z0 + 7, 4, 4, colors[(index + 2) % colors.size()])
		index += 1
	for x0 in range(_land.low.x + 6, _land.high.x - 4, 13):
		var z: int = RIVER_NORTH + 1 + _land.noise(x0, 2) % 3
		for x in range(x0, x0 + 3):
			_terrain.set_cell_item(Vector3i(x, _land.top(x, z), z), _item("Tábuas"))


func _house(x0: int, z0: int, width: int, depth: int, color: String) -> void:
	var base: int = _land.top(x0, z0)
	for z in range(z0, z0 + depth):
		for x in range(x0, x0 + width):
			if _land.kind(x, z) != _land.Kind.FILL:
				return
	for z in range(z0, z0 + depth):
		for x in range(x0, x0 + width):
			var wall := x == x0 or x == x0 + width - 1 or z == z0 or z == z0 + depth - 1
			var door := z == z0 and x == x0 + 1
			for y in range(base, base + 3):
				if wall and not (door and y < base + 2):
					_terrain.set_cell_item(Vector3i(x, y, z), _item(color))
			_terrain.set_cell_item(Vector3i(x, base + 3, z), _item("Telhado"))
			if x > x0 and x < x0 + width - 1:
				_terrain.set_cell_item(Vector3i(x, base + 4, z), _item("Telhado"))


# Esteios de madeira velha subindo da água escura até a beira das galerias.
func _mine_post(x: int, z: int) -> void:
	if _land.distance(x, z) != 2 or _land.chance(x, z, 7) > 0.18:
		return
	var floor_level: int = _land.base(x, z)
	for y in range(_land.top(x, z), floor_level):
		_set_if_empty(Vector3i(x, y, z), _item("Tronco"))


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


func _build_objects(_player: Node3D) -> void:
	var objects := Node3D.new()
	objects.name = "Objects"
	_add(_root, objects)
	var mobs := Node3D.new()
	mobs.name = "Mobs"
	_add(_root, mobs)
	var seen := {}
	var flee_point: Marker3D
	var lever: Node3D
	var gate_cells: Array[Vector2i] = []
	var arena_entry: Array[Vector2i] = []
	var arena_exit: Array[Vector2i] = []
	var spawns := []
	var optional := {"i": [], "j": [], "u": []}
	var cracked: Array[Vector2i] = []
	for z in _rows.size():
		for x in _rows[z].length():
			var ch := _cell(x, z)
			match ch:
				"S":
					var start := _respawn(objects, &"prologue_start", _center(x, z), PI)
					_root.set("start_point", start)
				"E":
					if not seen.has("E"):
						seen["E"] = true
						_respawn(objects, &"mine_entrance", Vector3(x + 1, _ground(x, z), z + 0.5), 0.0)
				"F":
					flee_point = Marker3D.new()
					flee_point.name = "FleePoint"
					flee_point.position = _center(x, z)
					_add(objects, flee_point)
				"W":
					_mob(mobs, "res://mobs/wolf.tscn", "mine_wolf", _center(x, z))
				"K":
					_mob(mobs, "res://mobs/skeleton.tscn", "mine_skeleton", _center(x, z))
				"b":
					_pickup(objects, &"mine_slingshot", &"slingshot", _center(x, z))
				"p":
					# O desvio do fim da sala do baú guarda +20 de vida (08-mapa).
					var hidden := _instance(objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					hidden.set("save_id", &"heart_mine_2")
					hidden.set("item_id", &"heart")
					hidden.set("upgrade", true)
				"C":
					var chest := _instance(objects, "res://world/objects/chest.tscn", _center(x, z), PI)
					chest.set("save_id", &"mine_chest_cloak")
					chest.set("item_id", &"fiber_cloak")
				"L":
					lever = _instance(objects, "res://world/objects/lever.tscn", _center(x, z), PI)
					lever.set("save_id", &"mine_lever")
				"G":
					gate_cells.append(Vector2i(x, z))
				"r":
					var rock := _instance(objects, "res://world/traps/falling_rock.tscn", _center(x, z), 0.0)
					rock.set("save_id", _next_id("mine_rock"))
				"l":
					_instance(objects, "res://world/objects/lamp.tscn", _center(x, z), 0.0)
				"a":
					(arena_exit if z < 20 else arena_entry).append(Vector2i(x, z))
				"o":
					var spot := Marker3D.new()
					spot.name = "ArenaSpawn"
					spot.position = _center(x, z)
					spot.rotation.y = PI
					_add(objects, spot)
					spawns.append(spot)
				"V":
					if not seen.has("V"):
						seen["V"] = true
						# Desce para o Bosque; na volta, Nate chega em cima dele (08-mapa).
						var elevator := _instance(objects, "res://world/objects/elevator.tscn", Vector3(x + 1.5, _ground(x, z), z + 1.5), 0.0)
						elevator.set("save_id", &"mine_elevator")
						elevator.set("destination", "res://world/areas/forest.tscn")
						elevator.set("destination_arrival", &"forest_elevator")
						elevator.set("arrival_id", &"mine_elevator")
						elevator.set("travel_direction", -1)
						elevator.set("repair_id", &"elevator_repaired")
				"X":
					cracked.append(Vector2i(x, z))
				"y":
					# Atrás da parede rachada da sala do baú, +1 carga (volta com a Terra, 08-mapa).
					var wall_charge := _instance(objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					wall_charge.set("save_id", &"charge_mine_2")
					wall_charge.set("item_id", &"charge")
					wall_charge.set("upgrade", true)
				"q":
					var charge := _instance(objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					charge.set("save_id", &"charge_mine_1")
					charge.set("item_id", &"charge")
					charge.set("upgrade", true)
				"i", "j", "u":
					optional[ch].append(Vector2i(x, z))
				"h":
					# +20 de vida no canto escuro: volta com a Luz Ancestral (08-mapa).
					var upgrade := _instance(objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					upgrade.set("save_id", &"heart_mine_1")
					upgrade.set("item_id", &"heart")
					upgrade.set("upgrade", true)
				"P":
					var wolf := _mob(mobs, "res://mobs/prologue_wolf.tscn", "", _center(x, z))
					wolf.set("save_id", &"prologue_wolf")
					wolf.set_meta(&"needs_flee_point", true)
	for mob in mobs.get_children():
		if mob.has_meta(&"needs_flee_point"):
			mob.remove_meta(&"needs_flee_point")
			mob.set("flee_point", flee_point)
	var gate := _gate(objects, gate_cells, 2)
	gate.set("lever", lever)
	_build_arena(objects, arena_entry, arena_exit, spawns)
	_build_dark_areas(objects)
	_build_optional_arena(objects, optional)
	_build_cracked_walls(objects, cracked)
	# Mural 1 (08-mapa): na parede leste do túnel onde a mina encontra os túneis do povo antigo, virado para oeste.
	var mural := _instance(objects, "res://world/objects/mural.tscn", Vector3(40.95, _ground(40, 33), 33.0), PI / 2.0)
	mural.name = "Mural1"
	mural.set("mural_id", 1)


# Arena opcional da Mina (08-mapa): atrás da parede rachada do túnel do mural; guarda +1 carga.
func _build_optional_arena(objects: Node3D, cells: Dictionary) -> void:
	var entry := _gate(objects, Array(cells["i"], TYPE_VECTOR2I, &"", null), 2)
	var exit_gate := _gate(objects, Array(cells["j"], TYPE_VECTOR2I, &"", null), 2)
	entry.set("starts_open", true)
	exit_gate.set("starts_open", false)
	var spots := []
	for cell: Vector2i in cells["u"]:
		var spot := Marker3D.new()
		spot.name = "ArenaSpawn"
		spot.position = _center(cell.x, cell.y)
		spot.rotation.y = PI
		_add(objects, spot)
		spots.append(spot)
	var arena: Node3D = (load("res://world/arena.gd") as GDScript).new()
	arena.name = "OptionalArena"
	arena.position = Vector3(15, _ground(15, 28), 28)
	arena.set("save_id", &"mine_arena_optional")
	arena.set("area_size", Vector2(16, 14))
	arena.set("waves", _typed([load("res://data/arenas/mine_optional_wave_1.tres"), load("res://data/arenas/mine_optional_wave_2.tres")], &"Resource", "res://world/arena_wave.gd"))
	arena.set("gates", _typed([entry, exit_gate], &"StaticBody3D", "res://world/objects/gate.gd"))
	arena.set("spawn_points", Array(spots, TYPE_OBJECT, &"Node3D", null))
	_add(objects, arena)


# Paredes rachadas (08-mapa): cada grupo de blocos marcados vira uma parede, que quebra com a Terra.
func _build_cracked_walls(objects: Node3D, cells: Array[Vector2i]) -> void:
	var left := cells.duplicate()
	while not left.is_empty():
		var group: Array[Vector2i] = [left.pop_back()]
		var index := 0
		while index < group.size():
			for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if group[index] + side in left:
					left.erase(group[index] + side)
					group.append(group[index] + side)
			index += 1
		var low := group[0]
		var high := group[0]
		for cell in group:
			low = low.min(cell)
			high = high.max(cell)
		var wall := _instance(objects, "res://world/objects/cracked_wall.tscn", Vector3((low.x + high.x + 1) / 2.0, _ground(low.x, low.y), (low.y + high.y + 1) / 2.0), 0.0)
		wall.set("save_id", _next_id("mine_cracked_wall"))
		wall.set("size", Vector3(high.x - low.x + 1, 2, high.y - low.y + 1))
		wall.set("material", (_library.get_item_mesh(_item("Parede rachada")) as BoxMesh).material)


# Áreas escuras (08-mapa): cada mancha de chão escuro vira um retângulo com a tampa de escuridão e a barreira.
func _build_dark_areas(objects: Node3D) -> void:
	var done := {}
	for z in _rows.size():
		for x in _rows[z].length():
			if _cell(x, z) != "d" or done.has(Vector2i(x, z)):
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
					if _cell(next.x, next.y) == "d" and not done.has(next):
						done[next] = true
						queue.append(next)
			var dark: Node3D = (load("res://world/dark_area.gd") as GDScript).new()
			dark.name = "DarkArea"
			dark.position = Vector3((low.x + high.x + 1) / 2.0, _ground(x, z), (low.y + high.y + 1) / 2.0)
			dark.set("area_size", Vector2(high - low + Vector2i.ONE))
			dark.set("cover_height", 2.05)
			dark.set("mask", _dark_mask(region, low, high))
			dark.set("margin", 1.0)
			dark.set("darkness", 0.9)
			dark.set("edge_resolution", 8)
			dark.set("wobble_size", 1.5)
			dark.set("wobble", 0.35)
			dark.set("edge_start", 0.2)
			dark.set("edge_end", 0.8)
			_add(objects, dark)


func _build_arena(objects: Node3D, entry: Array[Vector2i], exit_cells: Array[Vector2i], spawns: Array) -> void:
	var entry_gate := _gate(objects, entry, entry.size())
	var exit_gate := _gate(objects, exit_cells, exit_cells.size())
	entry_gate.set("starts_open", true)
	exit_gate.set("starts_open", false)
	var arena: Node3D = (load("res://world/arena.gd") as GDScript).new()
	arena.name = "Arena"
	arena.position = Vector3(39, _ground(39, 19), 19)
	arena.set("save_id", &"mine_arena")
	arena.set("area_size", Vector2(16, 14))
	arena.set("waves", _typed([load("res://data/arenas/mine_wave_1.tres"), load("res://data/arenas/mine_wave_2.tres")], &"Resource", "res://world/arena_wave.gd"))
	arena.set("gates", _typed([entry_gate, exit_gate], &"StaticBody3D", "res://world/objects/gate.gd"))
	arena.set("spawn_points", Array(spawns, TYPE_OBJECT, &"Node3D", null))
	_add(objects, arena)


# Portão no meio das células marcadas, virado para atravessar a passagem.
func _gate(parent: Node3D, cells: Array[Vector2i], width: int) -> Node3D:
	var center := Vector2.ZERO
	for cell in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var along_z := cells.size() > 1 and cells[0].x == cells[1].x
	return _instance(parent, "res://world/objects/gate_%d.tscn" % width, Vector3(center.x, _ground(center.x, center.y), center.y), PI / 2.0 if along_z else 0.0)


func _respawn(parent: Node3D, id: StringName, where: Vector3, facing: float) -> Node3D:
	var point: Marker3D = (load("res://world/respawn_point.gd") as GDScript).new()
	point.name = String(id).to_pascal_case()
	point.position = where
	point.rotation.y = facing
	point.set("id", id)
	point.set("radius", 2.0)
	_add(parent, point)
	return point


func _mob(parent: Node3D, scene_path: String, id_prefix: String, where: Vector3) -> Node3D:
	var mob := _instance(parent, scene_path, where, PI)
	if id_prefix != "":
		mob.set("save_id", _next_id(id_prefix))
	return mob


func _pickup(parent: Node3D, save_id: StringName, item_id: StringName, where: Vector3) -> void:
	var pickup := _instance(parent, "res://world/objects/item_pickup.tscn", where, 0.0)
	pickup.set("save_id", save_id)
	pickup.set("item_id", item_id)


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
	director.set("start_hints", _typed([load("res://data/ui/hint_move.tres"), load("res://data/ui/hint_attack.tres"), load("res://data/ui/hint_dodge.tres")], &"Resource", "res://ui/hint_data.gd"))
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
