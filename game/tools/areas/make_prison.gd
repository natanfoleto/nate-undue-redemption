extends SceneTree
# Monta a Grande Prisão (world/areas/prison.tscn) a partir dos rascunhos em texto (prison_layout.txt e
# prison_heights.txt; o montador do terreno explica o formato). Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_prison.gd
#
# A construção do povo antigo, em pedra escura com pilastras de jade: o corredor que chega das Ruínas, a antessala
# com o S4 e o mural 7, a porta da Grande Prisão e a arena da Boiúna, com o fosso no centro e os 4 pilares. Em volta,
# rocha subindo atrás e, na frente da câmera, o abismo com a escuridão do predador no fundo.

const FOLDER := "res://tools/areas/"
const LAYOUT := FOLDER + "prison_layout.txt"
const HEIGHTS := FOLDER + "prison_heights.txt"
const BUILDER := FOLDER + "terrain_builder.gd"
const AREA_PATH := "res://world/areas/prison.tscn"

# Caracteres do rascunho que são chão (os pilares ficam em cima do chão da arena) e o fosso.
const FLOOR_CHARS := ".,4RxDP"
const CHASM_CHARS := "~"
const ARENA_CHARS := ",P~"
const JADE_LIGHT := Color("6fe8b0")
const DARK_LIGHT := Color("8a3ac0")
# Pilastras de jade nas paredes de trás: uma a cada tantos blocos; e uma luz a cada tantas pilastras, na antessala e
# na parede de trás da arena.
const PILASTER_EVERY := 4
const PILASTER_LIGHT_EVERY := 8
# Luzes do fundo do abismo: uma a cada tantos blocos, até esta distância do chão.
const DARK_LIGHT_EVERY := 7
const DARK_LIGHT_REACH := 9
# A escuridão da fase 2 cobre a arena até o alto das paredes de trás.
const DARK_COVER := 5.05

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
var _world: WorldEnvironment
var _arena_lights: Array[Light3D] = []


func _initialize() -> void:
	_rows = FileAccess.get_file_as_string(LAYOUT).split("\n")
	_root = (load("res://world/area_level.gd") as GDScript).new()
	_root.name = "Prison"
	# Na prisão, silêncio grave: só o som de fundo e a respiração da Boiúna no fosso (10-arte-audio).
	_root.set("ambience", load("res://assets/audio/ambience/dungeon_ambient_1.ogg"))
	_build_lighting()
	_build_terrain()
	var player := _build_player()
	_build_objects()
	var director := _build_interface(player)
	_build_arena(player, director)
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
	return Vector3(x + 0.5, _land.ground(floori(x), floori(z)), z + 0.5)


func _item(item_name: String) -> int:
	if not _items.has(item_name):
		var index := _library.find_item_by_name(item_name)
		assert(index >= 0, "bloco que falta na biblioteca: " + item_name)
		_items[item_name] = index
	return _items[item_name]


# Pedra escura e luz fria; a luz do ambiente é a da fase 1 (a arena acesa), e a luta a apaga na fase 2.
func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("08080d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.62, 0.78)
	environment.ambient_light_energy = 0.75
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	environment.glow_bloom = 0.05
	_world = WorldEnvironment.new()
	_world.name = "WorldEnvironment"
	_world.environment = environment
	_add(_root, _world)


func _build_terrain() -> void:
	_library = load("res://world/blocks/prison_blocks.tres")
	_terrain = _grid("Terrain", HitShape.WORLD_LAYER)
	_sight = _grid("Sight", HitShape.WORLD_LAYER)
	_barriers = _grid("Barriers", HitShape.BARRIER_LAYER)
	_decor = _grid("Decor", 0)
	_land = (load(BUILDER) as GDScript).new()
	_land.floor_chars = FLOOR_CHARS
	_land.chasm_chars = CHASM_CHARS
	_land.setup(_rows, FileAccess.get_file_as_string(HEIGHTS).split("\n"))
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			_place_column(x, z)
	_decorate()


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
			_land.place_floor(_terrain, x, z, _item(_floor_block(x, z)), _item("Rocha"), _item("Escada"))
			for y in range(_land.bottom(x, z), _land.height(x, z) - 1):
				_terrain.set_cell_item(Vector3i(x, y, z), _item("Rocha funda"))
		_land.Kind.CHASM:
			# O fosso: a escuridão do predador no fundo; a barreira segura quem anda na beira (sem cerca).
			_land.place_column(_terrain, x, z, _item("Escuridão"), _item("Rocha funda"))
			_land.place_edge(_barriers, _decor, x, z, _item("Invisível"), -1)
		_:
			if _cell(x, z) == "7":
				_land.place_column(_terrain, x, z, _item("Lugar do mural"), _item("Lugar do mural"), _item("Rocha funda"))
			elif _land.is_bottom(x, z):
				_land.place_column(_terrain, x, z, _item("Escuridão"), _item("Rocha funda"))
			elif _land.kind(x, z) == _land.Kind.WALL:
				var pilaster: bool = not _land.is_front(x, z) and posmod(x + z, PILASTER_EVERY) == 0
				_land.place_column(_terrain, x, z, _item("Padrão de jade" if pilaster else "Pedra da prisão"),
					_item("Pedra da prisão"), _item("Rocha funda"))
				if pilaster:
					for y in range(_land.base(x, z), _land.top(x, z)):
						_terrain.set_cell_item(Vector3i(x, y, z), _item("Padrão de jade"))
					if posmod(x + z, PILASTER_LIGHT_EVERY) == 0:
						_pilaster_light(x, z)
			else:
				_land.place_column(_terrain, x, z, _item("Rocha"), _item("Rocha"), _item("Rocha funda"))
			_land.place_sight(_sight, x, z, _item("Invisível"))


# O piso: o da prisão no corredor e na antessala; o da arena, mais escuro, com o anel de jade em volta do fosso.
func _floor_block(x: int, z: int) -> String:
	if _cell(x, z) not in [",", "P"]:
		return "Piso da prisão"
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			if _cell(x + dx, z + dz) == "~":
				return "Padrão de jade"
	return "Piso da arena"


# Uma luz de jade na frente da pilastra, do lado do chão.
func _pilaster_light(x: int, z: int) -> void:
	var source: Vector2i = _land.source(x, z)
	var toward := Vector3(source.x - x, 0.0, source.y - z).normalized() * 0.8
	var light := _light(Vector3(x + 0.5, _land.base(x, z) + 2.0, z + 0.5) + toward, JADE_LIGHT, 6.0, 1.0)
	if _cell(source.x, source.y) in ARENA_CHARS:
		_arena_lights.append(light)


# Luzes roxas no fundo do abismo da frente, perto do chão: a escuridão do predador.
func _decorate() -> void:
	for z in range(_land.low.y, _land.high.y):
		for x in range(_land.low.x, _land.high.x):
			if not _land.is_bottom(x, z) or _land.kind(x, z) == _land.Kind.CHASM:
				continue
			if x % DARK_LIGHT_EVERY == 0 and z % DARK_LIGHT_EVERY == 0 and _land.distance(x, z) <= DARK_LIGHT_REACH:
				_light(Vector3(x + 0.5, _land.top(x, z) + 1.5, z + 0.5), DARK_LIGHT, 8.0, 1.4)


func _light(where: Vector3, color: Color, light_range: float, energy: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = "JadeLight" if color == JADE_LIGHT else "DarkLight"
	light.position = where
	light.light_color = color
	light.omni_range = light_range
	light.light_energy = energy
	_add(_root, light)
	return light


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
	var cells := {}
	for z in _rows.size():
		for x in _rows[z].length():
			cells.get_or_add(_cell(x, z), []).append(Vector2i(x, z))
	var start: Vector2i = cells["R"][0]
	_root.set("start_point", _respawn(&"prison_entrance", _center(start.x, start.y), -PI / 2.0))
	var shrine: Vector2i = cells["4"][0]
	var sanctuary := _instance(_objects, "res://world/objects/sanctuary.tscn", _center(shrine.x, shrine.y), -PI / 2.0)
	sanctuary.name = "Sanctuary4"
	sanctuary.set("data", load("res://data/sanctuaries/s4.tres"))
	_build_mural(7, cells["7"], PI)
	_build_exit(cells["x"])


# O mural na frente da parede marcada, virado para a sala.
func _build_mural(id: int, cells: Array, facing: float) -> void:
	var center := Vector2.ZERO
	for cell: Vector2i in cells:
		center += Vector2(cell) + Vector2(0.5, 0.5)
	center /= cells.size()
	var front := Vector3.FORWARD.rotated(Vector3.UP, facing)
	var mural := _instance(_objects, "res://world/objects/mural.tscn", Vector3(center.x, _land.ground(floori(center.x), floori(center.y)), center.y) + front * 0.55, facing)
	mural.name = "Mural%d" % id
	mural.set("mural_id", id)


# A volta para as Ruínas, na ponta do corredor.
func _build_exit(cells: Array) -> void:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell: Vector2i in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	var exit: Node3D = (load("res://world/area_exit.gd") as GDScript).new()
	exit.name = "AreaExit"
	exit.position = Vector3((low.x + high.x) / 2.0 + 0.5, 0.0, (low.y + high.y) / 2.0 + 0.5)
	exit.set("area_size", high - low + Vector2.ONE)
	exit.set("next_area", "res://world/areas/ruins.tscn")
	exit.set("arrival", &"ruins_from_prison")
	_add(_objects, exit)


# A arena: a porta, os pilares (do norte, no sentido do relógio), a Boiúna no fosso, a escuridão da fase 2, a tampa
# de jade do fim e quem conduz a luta, por último (depois de todos estarem prontos).
func _build_arena(player: Node3D, director: Node) -> void:
	var cells := {}
	for z in _rows.size():
		for x in _rows[z].length():
			cells.get_or_add(_cell(x, z), []).append(Vector2i(x, z))
	var pit := _bounds(cells["~"])
	var center := Vector3(pit.get_center().x, 0.0, pit.get_center().y)
	var floor_cells: Array = []
	for ch in ARENA_CHARS:
		floor_cells.append_array(cells[ch])
	var arena := _bounds(floor_cells)
	var door_box := _bounds(cells["D"])
	var door := _instance(_objects, "res://world/objects/prison_door.tscn", Vector3(door_box.get_center().x, 0.0, door_box.get_center().y), PI / 2.0)
	door.set("save_id", &"prison_door")
	var pillars: Array[Node3D] = []
	var spots := _groups(cells["P"]).map(func(group: Array) -> Vector2: return _bounds(group).get_center())
	spots.sort_custom(func(a: Vector2, b: Vector2) -> bool: return _clock_angle(a - pit.get_center()) < _clock_angle(b - pit.get_center()))
	for i in spots.size():
		var pillar := _instance(_objects, "res://world/objects/prison_pillar.tscn", Vector3(spots[i].x, 0.0, spots[i].y), 0.0)
		pillar.name = "PrisonPillar%d" % (i + 1)
		pillars.append(pillar)
	var boiuna := _instance(_objects, "res://boss/boiuna.tscn", center, 0.0)
	boiuna.set("arena_rect", arena)
	boiuna.set("pit_half_size", pit.size.x / 2.0)
	var dark: Node3D = (load("res://world/dark_area.gd") as GDScript).new()
	dark.name = "ArenaDarkness"
	dark.position = Vector3(arena.get_center().x, 0.0, arena.get_center().y)
	dark.set("area_size", arena.size)
	dark.set("cover_height", DARK_COVER)
	dark.set("mask", _dark_mask(floor_cells, Vector2i(arena.position), Vector2i(arena.end) - Vector2i.ONE))
	dark.set("margin", 1.0)
	dark.set("darkness", 0.9)
	dark.set("edge_resolution", 8)
	dark.set("wobble_size", 1.5)
	dark.set("wobble", 0.35)
	dark.set("edge_start", 0.2)
	dark.set("edge_end", 0.8)
	dark.set("starts_dark", false)
	_add(_objects, dark)
	var seal := Node3D.new()
	seal.name = "PitSeal"
	seal.position = center
	_add(_objects, seal)
	var lid := MeshInstance3D.new()
	lid.name = "Lid"
	lid.mesh = _library.get_item_mesh(_item("Padrão de jade"))
	lid.scale = Vector3(pit.size.x, 0.25, pit.size.y)
	lid.position.y = -0.125
	_add(seal, lid)
	var fight: Node3D = (load("res://boss/boiuna_arena.gd") as GDScript).new()
	fight.name = "BoiunaArena"
	fight.position = center
	fight.set("save_id", &"prison_sealed")
	fight.set("phase_2_id", &"boiuna_phase_2")
	fight.set("ending_id", &"ending_seen")
	# A luta começa um bloco para dentro do chão da arena, longe da porta que fecha.
	fight.set("area_size", arena.size - Vector2.ONE)
	fight.set("boiuna", boiuna)
	fight.set("door", door)
	fight.set("pillars", _typed(pillars, &"StaticBody3D", "res://world/objects/prison_pillar.gd"))
	fight.set("dark_area", dark)
	fight.set("world", _world)
	fight.set("lit_ambient", 0.75)
	fight.set("dark_ambient", 0.12)
	fight.set("arena_lights", Array(_arena_lights, TYPE_OBJECT, &"Light3D", null))
	fight.set("camera", _root.get_node("FollowCamera"))
	fight.set("seal", seal)
	fight.set("chain_scene", load("res://world/effects/light_chain.tscn"))
	fight.set("hint_director", director)
	fight.set("pillar_hint", load("res://data/ui/hint_pillar.tres"))
	fight.set("sanctuary", load("res://data/sanctuaries/s4.tres"))
	fight.set("music", load("res://assets/audio/music/twists.mp3"))
	fight.set("ending_music", load("res://assets/audio/music/great_mission.mp3"))
	fight.set("ending_scenes", Array([load("res://world/memories/ending.tscn"), load("res://ui/credits.tscn"),
		load("res://ui/summary_screen.tscn")], TYPE_OBJECT, &"PackedScene", null))
	fight.set("focus_weight", 0.5)
	fight.set("focus_time", 1.0)
	fight.set("chain_time", 0.5)
	fight.set("thrash_time", 2.4)
	fight.set("chain_breaks", Array([0.8, 1.4], TYPE_FLOAT, &"", null))
	fight.set("dark_time", 1.5)
	fight.set("seal_pull_time", 2.0)
	fight.set("seal_close_time", 0.6)
	fight.set("seal_hold_time", 1.5)
	fight.set("breath_every", 6.0)
	_add(_objects, fight)


# O ângulo de um ponto em volta do centro, a partir do norte, no sentido do relógio.
static func _clock_angle(offset: Vector2) -> float:
	return fposmod(atan2(offset.x, -offset.y), TAU)


func _bounds(cells: Array) -> Rect2:
	var low := Vector2(cells[0])
	var high := Vector2(cells[0])
	for cell: Vector2i in cells:
		low = low.min(Vector2(cell))
		high = high.max(Vector2(cell))
	return Rect2(low, high - low + Vector2.ONE)


# Blocos marcados que se tocam formam um grupo (um pilar inteiro).
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


func _dark_mask(region: Array, low: Vector2i, high: Vector2i) -> ImageTexture:
	var image := Image.create_empty(high.x - low.x + 3, high.y - low.y + 3, false, Image.FORMAT_L8)
	for cell: Vector2i in region:
		image.set_pixel(cell.x - low.x + 1, cell.y - low.y + 1, Color.WHITE)
	return ImageTexture.create_from_image(image)


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


func _build_interface(player: Node3D) -> Node:
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
	_add(_root, (load("res://ui/pause_menu.tscn") as PackedScene).instantiate())
	_add(_root, (load("res://ui/inventory.tscn") as PackedScene).instantiate())
	_add(_root, (load("res://ui/mural_gallery.tscn") as PackedScene).instantiate())
	return director


# Lista tipada com um script carregado só agora: os tipos que dependem dos sistemas globais não compilam antes.
func _typed(items: Array, base: StringName, script_path: String) -> Array:
	return Array(items, TYPE_OBJECT, base, load(script_path))


func _add(parent: Node, node: Node) -> void:
	parent.add_child(node, true)
	node.owner = _root
