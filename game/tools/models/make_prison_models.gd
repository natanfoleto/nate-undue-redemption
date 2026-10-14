extends SceneTree
# Monta os modelos da Grande Prisão (07-chefes/boiuna, 08-mapa) com a pele pintada no molde das skins do Minecraft:
# o pilar de pedra escura com a faixa e o cristal de jade (que acendem quando o pilar ativa), a moldura e a laje da
# porta, com o muiraquitã em relevo, e as peças da Boiúna (a cabeça, com a mandíbula, os olhos âmbar e o reflexo roxo,
# e o gomo do corpo, que o jogo repete e estica). Rodar a partir da raiz do repositório, em três passos: as peles, a
# importação e os modelos:
#   godot --headless --path game -s res://tools/models/make_prison_models.gd
#   godot --headless --path game --import
#   godot --headless --path game -s res://tools/models/make_prison_models.gd -- --model

const MODELS := "res://data/models/"
const SKINS := "res://assets/textures/"
const WIDTH := 256

const STONE := Color("5c5c70")
const STONE_DARK := Color("48485a")
const STONE_LIGHT := Color("70708a")
const JOINT := Color("3a3a4a")
const JADE := Color("3fae8a")
const JADE_DARK := Color("2a6a58")
const JADE_LIGHT := Color("8fe8c8")
const SCALE := Color("221a2a")
const SCALE_ALT := Color("2c2236")
const SCALE_EDGE := Color("100c14")
const SCALE_SHINE := Color("5a3e78")
const BELLY := Color("4a3e56")
const BELLY_LINE := Color("2e2638")
const SHEEN := Color("5a2a80")
const SHEEN_LIGHT := Color("8a50b0")
const EYE := Color("f2a030")
const EYE_LIGHT := Color("ffd070")
const PUPIL := Color("1a0e00")
const FANG := Color("e8e0c8")

const FRONT := BoxData.Face.FRONT
const BACK := BoxData.Face.BACK
const RIGHT := BoxData.Face.RIGHT
const LEFT := BoxData.Face.LEFT
const TOP := BoxData.Face.TOP
const BOTTOM := BoxData.Face.BOTTOM


func _initialize() -> void:
	var write_models := "--model" in OS.get_cmdline_user_args()
	var shapes := {
		# Baixos (pouco mais que Nate), para não esconder a luta da câmera.
		"prison_pillar": [
			_b("base", Vector3i(32, 4, 32), Vector3(-16, 0, -16)),
			_b("shaft", Vector3i(24, 26, 24), Vector3(-12, 4, -12)),
			_b("band", Vector3i(26, 4, 26), Vector3(-13, 14, -13)),
			_b("capital", Vector3i(30, 4, 30), Vector3(-15, 30, -15)),
			_b("crystal", Vector3i(8, 8, 8), Vector3(-4, 34, -4)),
		],
		# Na altura dos portões das arenas: a porta fica numa parede baixa, de frente para a câmera.
		"prison_door_frame": [
			_b("post_l", Vector3i(8, 40, 10), Vector3(-40, 0, -5)),
			_b("post_r", Vector3i(8, 40, 10), Vector3(32, 0, -5)),
			_b("lintel", Vector3i(80, 6, 12), Vector3(-40, 38, -6)),
		],
		"prison_door_slab": [
			_b("slab", Vector3i(64, 38, 6), Vector3(-32, 0, -3)),
			_b("emblem", Vector3i(16, 14, 1), Vector3(-8, 12, -4)),
			_b("emblem_back", Vector3i(16, 14, 1), Vector3(-8, 12, 3)),
		],
		# A cabeça presa ao pescoço no ponto de giro (o meio da nuca, onde o corpo encaixa), virada para a frente (−z);
		# a mandíbula abre pela dobradiça, atrás.
		"boiuna_skull": [
			_b("head", Vector3i(22, 14, 30), Vector3(-11, -7, -30)),
			_b("jaw", Vector3i(18, 4, 24), Vector3(-9, -11, -26), Vector3(0, -7, -2)),
			_b("eye_r", Vector3i(2, 3, 4), Vector3(11, 0, -26)),
			_b("eye_l", Vector3i(2, 3, 4), Vector3(-13, 0, -26)),
			_b("sheen", Vector3i(6, 1, 18), Vector3(-3, 7, -24)),
		],
		"boiuna_segment": [
			_b("segment", Vector3i(16, 16, 16), Vector3(-8, -8, -8)),
		],
	}
	for model_name: String in shapes:
		var boxes: Array[BoxData] = []
		boxes.assign(shapes[model_name])
		var height := _place_regions(boxes)
		var skin_path := SKINS + model_name + "_skin.png"
		if write_models:
			var model := ModelData.new()
			model.boxes = boxes
			model.texture = load(skin_path)
			var path := MODELS + model_name + ".tres"
			print(path, ": ", error_string(ResourceSaver.save(model, path)))
			continue
		var image := Image.create_empty(WIDTH, height, false, Image.FORMAT_RGBA8)
		for box in boxes:
			var rects := box.face_rects()
			for face: int in rects:
				var rect: Rect2i = rects[face]
				for v in rect.size.y:
					for u in rect.size.x:
						image.set_pixel(rect.position.x + u, rect.position.y + v, _paint(model_name, box, face, u, v, rect.size.x, rect.size.y))
		print(skin_path, ": ", error_string(image.save_png(ProjectSettings.globalize_path(skin_path))))
	quit()


func _b(box_name: String, size: Vector3i, position: Vector3, pivot := Vector3.ZERO) -> BoxData:
	var box := BoxData.new()
	box.name = StringName(box_name)
	box.size = size
	box.position = position
	box.pivot = pivot
	box.color = STONE
	return box


func _place_regions(boxes: Array[BoxData]) -> int:
	var cursor := Vector2i.ZERO
	var row_height := 0
	for box in boxes:
		var need := Vector2i(2 * box.size.z + 2 * box.size.x, box.size.z + box.size.y)
		if cursor.x + need.x > WIDTH:
			cursor = Vector2i(0, cursor.y + row_height)
			row_height = 0
		box.texture_offset = cursor
		cursor.x += need.x
		row_height = maxi(row_height, need.y)
	return cursor.y + row_height


func _noise(box: BoxData, face: int, u: int, v: int, salt := 0) -> float:
	return float(absi(hash([String(box.name), face, u, v, salt])) % 1000) / 1000.0


func _paint(model_name: String, box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match model_name:
		"prison_pillar":
			return _pillar(box, face, u, v, w, h)
		"prison_door_frame":
			return _stone_blocks(box, face, u, v, 8, 6)
		"prison_door_slab":
			return _slab(box, face, u, v, w, h)
		"boiuna_skull":
			return _skull(box, face, u, v, w, h)
	return _scales(box, face, u, v)


# Pedra em blocos: juntas escuras a cada tanto e manchas claras e escuras.
func _stone_blocks(box: BoxData, face: int, u: int, v: int, block_w: int, block_h: int) -> Color:
	var row := v / block_h
	var along := u + (row % 2) * (block_w / 2)
	if posmod(v, block_h) == block_h - 1 or posmod(along, block_w) == block_w - 1:
		return JOINT
	var n := _noise(box, face, u, v)
	if n < 0.12:
		return STONE_DARK
	return STONE_LIGHT if n > 0.92 else STONE


# O pilar: pedra em blocos com o losango entalhado em jade escuro no fuste; a faixa e o cristal de jade, que acendem.
func _pillar(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"band":
			return JADE_LIGHT if posmod(u, 4) == 1 and face != TOP and face != BOTTOM else JADE
		&"crystal":
			if u == v or u == v + 1:
				return JADE_LIGHT
			return JADE_DARK if u + v >= w + h - 4 else JADE
		&"shaft":
			if face != TOP and face != BOTTOM and v >= 4 and v <= h - 5:
				var zig := 2 + absi(posmod(v - 4, 12) - 6)
				if u == zig or u == w - 1 - zig:
					return JADE_DARK
	return _stone_blocks(box, face, u, v, 8, 6)


# A laje: pedra lisa com a borda, e o muiraquitã (um sapo de jade) em relevo no meio, dos dois lados.
func _slab(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	if box.name != &"slab":
		var frog := [
			"..XX....XX......",
			".XXXX..XXXX.....",
			".XXXXXXXXXX.....",
			"..XXXXXXXX......",
			"...XXXXXX.......",
			"..XXXXXXXX......",
			".XXXXXXXXXX.....",
			"XXX.XXXX.XXX....",
			"XX..XXXX..XX....",
			"X...XXXX...X....",
			"....XX..XX......",
			"...XX....XX.....",
			"..XX......XX....",
			"................",
		]
		var row: String = frog[mini(v, frog.size() - 1)]
		var mark := row[mini(u, row.length() - 1)] == "X"
		return JADE_LIGHT if mark and _noise(box, face, u, v) > 0.85 else JADE if mark else STONE_DARK
	if u <= 1 or u >= w - 2 or v <= 1 or v >= h - 2:
		return STONE_DARK
	var n := _noise(box, face, u, v)
	return STONE_LIGHT if n > 0.94 else STONE_DARK if n < 0.08 else STONE


# A cabeça da Boiúna: escamas, a barriga em placas, as narinas e as presas na frente, os olhos âmbar com a pupila em
# fenda e o reflexo roxo em cima.
func _skull(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"eye_r", &"eye_l":
			if (face == RIGHT or face == LEFT) and u == w / 2:
				return PUPIL
			return EYE_LIGHT if v == 0 else EYE
		&"sheen":
			if face == TOP:
				return SHEEN_LIGHT if u == w / 2 or u == w / 2 - 1 else SHEEN
			return SHEEN
		&"jaw":
			if face == BOTTOM:
				return BELLY_LINE if posmod(v, 3) == 2 else BELLY
			if face == FRONT and v == 0:
				return BELLY
		&"head":
			if face == FRONT:
				if v == 3 and (u == 6 or u == 7 or u == w - 7 or u == w - 8):
					return SCALE_EDGE
				if v >= h - 3 and (u == 4 or u == w - 5):
					return FANG
				if v == h - 1:
					return SCALE_EDGE
	if face == BOTTOM:
		return BELLY_LINE if posmod(v, 3) == 2 else BELLY
	return _scales(box, face, u, v)


func _scales(box: BoxData, face: int, u: int, v: int) -> Color:
	if face == BOTTOM:
		return BELLY_LINE if posmod(v, 3) == 2 else BELLY
	if box.name == &"segment" and face == TOP and u >= 6 and u <= 9:
		return SHEEN_LIGHT if u == 7 or u == 8 else SHEEN
	var row := v / 3
	var along := u + (row % 2) * 2
	var local := Vector2i(posmod(along, 4), posmod(v, 3))
	if local.y == 2 or local.x == 0:
		return SCALE_EDGE if local.y == 2 else SCALE
	if local.y == 0 and local.x == 1:
		return SCALE_SHINE
	return SCALE_ALT if absi(hash([String(box.name), face, floori(along / 4.0), row])) % 3 == 0 else SCALE
