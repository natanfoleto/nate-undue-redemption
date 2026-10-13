extends SceneTree
# Monta as Ruínas (world/areas/ruins.tscn) a partir dos rascunhos em texto (ruins_layout.txt e ruins_heights.txt; o
# montador do terreno explica o formato). Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_ruins.gd
#
# Em volta da cidade, rocha subindo em morros com restos de muros marajoara em cima; na frente da câmera, fendas de
# lava, que iluminam as paredes de baixo para cima.

const FOLDER := "res://tools/areas/"
const LAYOUT := FOLDER + "ruins_layout.txt"
const HEIGHTS := FOLDER + "ruins_heights.txt"
const BUILDER := FOLDER + "terrain_builder.gd"
const NAVIGATION_PATH := "res://world/areas/ruins_navigation.res"
const AREA_PATH := "res://world/areas/ruins.tscn"

# Caracteres do rascunho que são chão (onde se anda ou onde fica um objeto em cima do chão) e que são abismo: o vão
# (~) e o vão da ponte de alavanca (B), que a própria ponte segura.
const FLOOR_CHARS := ",.1237ACEGJKLNQRSTVWXYabcefghklpuvwx"
const CHASM_CHARS := "~B"
# Altura dos pilares de jade e da parede rachada; a parede baixa atrás de um mural sobe até cobrir o desenho.
const PILLAR_HEIGHT := 3
const CRACKED_HEIGHT := 2
const MURAL_WALL_HEIGHT := 2
const JADE_LIGHT := Color("6fe8b0")
const LAVA_LIGHT := Color("ff7a2e")
# Luzes da lava: uma a cada tantos blocos, até esta distância do chão.
const LAVA_LIGHT_EVERY := 7
const LAVA_LIGHT_REACH := 9
# Itens do chão: identificador no mapa, item e espaço.
const PICKUPS := {
	"w": [&"ruins_bow", &"bow", "ranged"],
	"c": [&"ruins_cuirass", &"cuirass", "armor"],
	"k": [&"ruins_stone_blade", &"stone_blade", "melee"],
}
const UPGRADES := {"h": [&"heart_ruins_1", &"heart"], "Q": [&"charge_ruins_1", &"charge"]}
const MOBS := {
	"K": ["res://mobs/skeleton.tscn", "ruins_skeleton"],
	"V": ["res://mobs/skeleton_veteran.tscn", "ruins_veteran"],
	"W": ["res://mobs/wolf.tscn", "ruins_wolf"],
	"A": ["res://mobs/wolf_alpha.tscn", "ruins_alpha"],
	"N": ["res://mobs/necromancer.tscn", "ruins_necromancer"],
	"E": ["res://mobs/necromancer_elder.tscn", "ruins_necromancer_elder"],
	"G": ["res://mobs/golem.tscn", "ruins_golem"],
	"O": ["res://mobs/golem_elder.tscn", "ruins_golem_elder"],
}

var _rows: PackedStringArray
var _root: Node3D
var _library: MeshLibrary
var _terrain: GridMap
var _barriers: GridMap
var _sight: GridMap
var _decor: GridMap
var _land: RefCounted
var _objects: Node3D
var _items := {}
var _counts := {}


func _initialize() -> void:
	_rows = FileAccess.get_file_as_string(LAYOUT).split("\n")
	_root = (load("res://world/area_level.gd") as GDScript).new()
	_root.name = "Ruins"
	_root.set("music", load("res://assets/audio/music/warped.mp3"))
	_root.set("ambience", load("res://assets/audio/ambience/dungeon_ambient_1.ogg"))
	_build_lighting()
	_build_terrain()
	var player := _build_player()
	_build_objects()
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


# A cidade e as minas antigas: luz ambiente quente e os padrões de jade acesos (10-arte-audio).
func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("0c0a08")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.75, 0.68, 0.6)
	environment.ambient_light_energy = 0.8
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	environment.glow_bloom = 0.05
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	world.environment = environment
	_add(_root, world)


func _build_terrain() -> void:
	_library = load("res://world/blocks/ruins_blocks.tres")
	_terrain = _grid("Terrain", HitShape.WORLD_LAYER)
	# Blocos invisíveis em cima das paredes baixas: seguram os tiros e a visão, como as outras paredes.
	_sight = _grid("Sight", HitShape.WORLD_LAYER)
	# Barreiras invisíveis na beira dos vãos: seguram quem anda, mas não os tiros nem a visão.
	_barriers = _grid("Barriers", HitShape.BARRIER_LAYER)
	# Enfeites sem colisão: a balaustrada.
	_decor = _grid("Decor", 0)
	_land = (load(BUILDER) as GDScript).new()
	_land.floor_chars = FLOOR_CHARS
	_land.chasm_chars = CHASM_CHARS
	_land.setup(_rows, FileAccess.get_file_as_string(HEIGHTS).split("\n"))
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if _cell(x, z) in ["4", "5", "6"] and _land.kind(x, z) == _land.Kind.WALL and _land.is_front(x, z):
				_land.set_wall_height(x, z, MURAL_WALL_HEIGHT)
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			_place_column(x, z)
	_decorate()
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
			if _cell(x, z) == "J":
				var h: int = _land.height(x, z)
				for y in range(h, h + PILLAR_HEIGHT):
					_terrain.set_cell_item(Vector3i(x, y, z), _item("Padrão de jade"))
				_light(Vector3(x + 0.5, h + 2.0, z + 0.5), JADE_LIGHT, 6.0, 1.2)
		_land.Kind.BRIDGE:
			_land.place_bridge(_terrain, x, z, _item("Piso marajoara"), _item("Parede marajoara"), 2, _item("Lava"), _item("Rocha queimada"))
		_land.Kind.CHASM:
			_land.place_column(_terrain, x, z, _item("Lava"), _item("Rocha queimada"))
			# O vão da ponte de alavanca não tem barreira de bloco: quem segura é a própria ponte, enquanto levantada.
			# Dos lados dela, a barreira segura quem atravessa, junto do corrimão da ponte.
			if _cell(x, z) != "B":
				_land.place_edge(_barriers, _decor, x, z, _item("Invisível"), _item("Balaustrada"))
			else:
				for side: Vector2i in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
					if _land.kind(x + side.x, z + side.y) == _land.Kind.FILL:
						_barriers.set_cell_item(Vector3i(x + side.x, _land.height(x, z), z + side.y), _item("Invisível"))
		_:
			match _cell(x, z):
				"4", "5", "6":
					_land.place_column(_terrain, x, z, _item("Pedra dos murais"), _item("Pedra dos murais"), _item("Rocha queimada"))
				_:
					if _land.is_bottom(x, z):
						_land.place_column(_terrain, x, z, _item("Lava"), _item("Rocha queimada"), _item("Rocha queimada"))
					elif _land.kind(x, z) == _land.Kind.WALL:
						_land.place_column(_terrain, x, z, _item("Parede marajoara"), _item("Parede marajoara"), _item("Rocha queimada"))
					else:
						_land.place_column(_terrain, x, z, _item("Rocha"), _item("Rocha"), _item("Rocha queimada"))
			_land.place_sight(_sight, x, z, _item("Invisível"))


func _floor(x: int, z: int) -> void:
	var ch := _cell(x, z)
	var mine := ch == ","
	if ch not in [".", ","]:
		for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if _cell(x + side.x, z + side.y) == ",":
				mine = true
	_land.place_floor(_terrain, x, z, _item("Chão das minas antigas") if mine else _item("Piso marajoara"), _item("Rocha"), _item("Escada"))
	# Abaixo do chão, a beira dos vãos é de rocha queimada, como as paredes deles.
	for y in range(_land.bottom(x, z), _land.height(x, z) - 1):
		_terrain.set_cell_item(Vector3i(x, y, z), _item("Rocha queimada"))


# Os enfeites de fora: restos de muros e de padrões de jade no alto dos morros, e as luzes da lava perto do caminho.
func _decorate() -> void:
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			var kind: int = _land.kind(x, z)
			if kind != _land.Kind.FILL and kind != _land.Kind.CHASM:
				continue
			var top: int = _land.top(x, z)
			if _land.is_bottom(x, z) or kind == _land.Kind.CHASM:
				if x % LAVA_LIGHT_EVERY == 0 and z % LAVA_LIGHT_EVERY == 0 and _land.distance(x, z) <= LAVA_LIGHT_REACH:
					_light(Vector3(x + 0.5, top + 1.5, z + 0.5), LAVA_LIGHT, 9.0, 2.2)
				continue
			var roll: float = _land.chance(x, z, 21)
			if top < _land.base(x, z) + 2 or roll > 0.07:
				continue
			# Resto de muro: de 1 a 3 blocos de parede marajoara, às vezes com o padrão de jade aceso em cima.
			var pieces: int = 1 + _land.noise(x, z) % 3
			for y in range(top, top + pieces):
				if y + 1 <= _land.cap(x, z):
					_set_if_empty(Vector3i(x, y, z), _item("Parede marajoara"))
			if roll < 0.012 and top + pieces + 1 <= _land.cap(x, z):
				_set_if_empty(Vector3i(x, top + pieces, z), _item("Padrão de jade"))


func _set_if_empty(where: Vector3i, item: int) -> void:
	if _terrain.get_cell_item(where) == GridMap.INVALID_CELL_ITEM:
		_terrain.set_cell_item(where, item)


func _light(where: Vector3, color: Color, light_range: float, energy: float) -> void:
	var light := OmniLight3D.new()
	light.name = "JadeLight" if color == JADE_LIGHT else "LavaLight"
	light.position = where
	light.light_color = color
	light.omni_range = light_range
	light.light_energy = energy
	_add(_root, light)


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
	var cells := {}
	for z in _rows.size():
		for x in _rows[z].length():
			var ch := _cell(x, z)
			cells.get_or_add(ch, []).append(Vector2i(x, z))
			match ch:
				"R":
					var arrival := _respawn(&"ruins_entrance", _center(x, z), 0.0)
					_root.set("start_point", arrival)
				"3":
					var sanctuary := _instance(_objects, "res://world/objects/sanctuary.tscn", _center(x, z), 0.0)
					sanctuary.name = "Sanctuary3"
					sanctuary.set("data", load("res://data/sanctuaries/s3.tres"))
				"C":
					var chest := _instance(_objects, "res://world/objects/chest.tscn", _center(x, z), PI)
					chest.set("save_id", &"ruins_chest_tacape")
					chest.set("item_id", &"tacape")
					chest.set("item_slot", "melee")
				"T", "Y":
					var scroll := _instance(_objects, "res://world/objects/scroll.tscn", _center(x, z), 0.0)
					var element := &"earth" if ch == "T" else &"air"
					scroll.name = "Scroll" + String(element).capitalize()
					scroll.set("save_id", StringName("ruins_scroll_" + element))
					scroll.set("element_id", element)
				"w", "c", "k":
					var spec: Array = PICKUPS[ch]
					var pickup := _instance(_objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					pickup.set("save_id", spec[0])
					pickup.set("item_id", spec[1])
					pickup.set("item_slot", spec[2])
				"h", "Q":
					var upgrade := _instance(_objects, "res://world/objects/item_pickup.tscn", _center(x, z), 0.0)
					upgrade.set("save_id", UPGRADES[ch][0])
					upgrade.set("item_id", UPGRADES[ch][1])
					upgrade.set("upgrade", true)
				"K", "V", "W", "A", "N", "E", "G", "O":
					var mob := _instance(mobs, MOBS[ch][0], _center(x, z), PI)
					mob.set("save_id", _next_id(MOBS[ch][1]))
				"p":
					# Fileiras vizinhas em ritmos diferentes: dá para passar entre elas.
					var spears := _instance(_objects, "res://world/traps/floor_spears.tscn", _center(x, z), 0.0)
					spears.set("phase_offset", fmod((x + z * 2) * 0.7, 4.0))
				"S":
					var altar := _instance(_objects, "res://world/objects/seal_altar.tscn", _center(x, z), 0.0)
					altar.set("save_id", &"ruins_seal")
	_build_bridge(cells["B"], cells["L"][0])
	_build_bow_gate(cells["g"], cells["l"])
	for group in _groups(cells["X"]):
		_build_cracked_wall(group)
	_build_mural(4, cells["4"], PI)
	_build_mural(5, cells["5"], 0.0)
	_build_mural(6, cells["6"], PI)
	_build_arena("RuinsArena1", &"ruins_arena_1", cells["a"], cells["b"], cells["1"], ["ruins_1_wave_1", "ruins_1_wave_2"])
	_build_arena("RuinsArena2", &"ruins_arena_2", cells["e"], cells["f"], cells["2"], ["ruins_2_wave_1", "ruins_2_wave_2"])
	_build_arena("RuinsArenaOptional", &"ruins_arena_optional", cells["u"], cells["v"], cells["7"],
		["ruins_optional_wave_1", "ruins_optional_wave_2", "ruins_optional_wave_3"])
	_build_exit(cells["x"])


# A ponte do vão a leste do S3: a dobradiça fica do lado do salão antes da arena 2, e ela baixa para o oeste.
func _build_bridge(cells: Array, lever_cell: Vector2i) -> void:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell: Vector2i in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	var lever := _instance(_objects, "res://world/objects/lever.tscn", _center(lever_cell.x, lever_cell.y), PI / 2.0)
	lever.set("save_id", &"ruins_bridge_lever")
	var bridge := _instance(_objects, "res://world/objects/lever_bridge.tscn", Vector3(high.x + 1, _ground(high.x + 1, low.y), (low.y + high.y + 1) / 2.0), PI / 2.0)
	bridge.set("lever", lever)
	bridge.set("span", Vector2(high.y - low.y + 1, high.x - low.x + 1))


# O portão do Arco: abre quando as 3 alavancas do outro lado do vão foram acertadas.
func _build_bow_gate(gate_cells: Array, lever_cells: Array) -> void:
	var levers: Array[Node3D] = []
	for i in lever_cells.size():
		var cell: Vector2i = lever_cells[i]
		var lever := _instance(_objects, "res://world/objects/lever.tscn", _center(cell.x, cell.y), PI)
		lever.set("save_id", StringName("ruins_bow_lever_%d" % (i + 1)))
		levers.append(lever)
	var gate := _gate(gate_cells)
	gate.set("lever", levers[0])
	gate.set("extra_levers", Array(levers.slice(1), TYPE_OBJECT, &"StaticBody3D", load("res://world/objects/lever.gd")))


func _build_cracked_wall(cells: Array) -> void:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell: Vector2i in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	var wall := _instance(_objects, "res://world/objects/cracked_wall.tscn", Vector3((low.x + high.x + 1) / 2.0, _ground(low.x, low.y), (low.y + high.y + 1) / 2.0), 0.0)
	wall.set("save_id", _next_id("ruins_cracked_wall"))
	wall.set("size", Vector3(high.x - low.x + 1, CRACKED_HEIGHT, high.y - low.y + 1))
	wall.set("material", _block_material(_item("Parede rachada")))


# O mural na frente da parede marcada, virado para a sala.
func _build_mural(id: int, cells: Array, facing: float) -> void:
	var center := Vector2.ZERO
	for cell: Vector2i in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var front := Vector3.FORWARD.rotated(Vector3.UP, facing)
	var mural := _instance(_objects, "res://world/objects/mural.tscn", Vector3(center.x, _ground(center.x, center.y), center.y) + front * 0.55, facing)
	mural.name = "Mural%d" % id
	mural.set("mural_id", id)


func _build_arena(node_name: String, save_id: StringName, entry: Array, exit_cells: Array, spawn_cells: Array, waves: Array) -> void:
	var entry_gate := _gate(entry)
	var exit_gate := _gate(exit_cells)
	entry_gate.set("starts_open", true)
	exit_gate.set("starts_open", false)
	var spawns: Array[Node3D] = []
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for cell: Vector2i in spawn_cells:
		var spot := Marker3D.new()
		spot.name = "ArenaSpawn"
		spot.position = _center(cell.x, cell.y)
		spot.rotation.y = PI
		_add(_objects, spot)
		spawns.append(spot)
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


func _gate(cells: Array) -> Node3D:
	var center := Vector2.ZERO
	for cell: Vector2i in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var along_z: bool = cells.size() > 1 and cells[0].x == cells[1].x
	return _instance(_objects, "res://world/objects/gate_%d.tscn" % cells.size(), Vector3(center.x, _ground(center.x, center.y), center.y), PI / 2.0 if along_z else 0.0)


# A saída depois do Selo: até a Grande Prisão existir, a parte jogável termina aqui.
func _build_exit(cells: Array) -> void:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell: Vector2i in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	var exit: Node3D = (load("res://world/area_exit.gd") as GDScript).new()
	exit.name = "AreaExit"
	exit.position = Vector3((low.x + high.x) / 2.0 + 0.5, _ground(low.x, low.y), (low.y + high.y) / 2.0 + 0.5)
	exit.set("area_size", high - low + Vector2.ONE)
	exit.set("needs_seal", true)
	_add(_objects, exit)
	_root.set("exit", exit)


# Blocos marcados que se tocam formam um grupo (uma parede rachada inteira).
func _groups(cells: Array) -> Array:
	var left := cells.duplicate()
	var groups := []
	while not left.is_empty():
		var group := [left.pop_back()]
		var index := 0
		while index < group.size():
			var cell: Vector2i = group[index]
			for side: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if cell + side in left:
					left.erase(cell + side)
					group.append(cell + side)
			index += 1
		groups.append(group)
	return groups


func _block_material(item: int) -> Material:
	return (_library.get_item_mesh(item) as BoxMesh).material


func _respawn(id: StringName, where: Vector3, facing: float) -> Node3D:
	var point: Marker3D = (load("res://world/respawn_point.gd") as GDScript).new()
	point.name = String(id).to_pascal_case()
	point.position = where
	point.rotation.y = facing
	point.set("id", id)
	point.set("automatic", false)
	_add(_objects, point)
	return point


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
	director.set("hints", hints)
	director.set("hint_scene", load("res://ui/button_hint.tscn"))
	_add(_root, director)
	var end_layer := CanvasLayer.new()
	end_layer.name = "EndLayer"
	end_layer.layer = 5
	_add(_root, end_layer)
	var end: Control = (load("res://ui/end_screen.tscn") as PackedScene).instantiate()
	end.set("text_key", &"RUINS_END")
	_add(end_layer, end)
	_root.set("end_screen", end)
	_add(_root, (load("res://ui/pause_menu.tscn") as PackedScene).instantiate())
	_add(_root, (load("res://ui/inventory.tscn") as PackedScene).instantiate())


# Lista tipada com um script carregado só agora: os tipos que dependem dos sistemas globais não compilam antes.
func _typed(items: Array, base: StringName, script_path: String) -> Array:
	return Array(items, TYPE_OBJECT, base, load(script_path))


func _add(parent: Node, node: Node) -> void:
	parent.add_child(node, true)
	node.owner = _root
