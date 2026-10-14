extends SceneTree
# Refaz o Nate com as proporções e a pele das skins do Minecraft (caixas retas, cabeça de 8 × 8 × 8, braços e pernas
# de 4 de largura) e a mesma roupa: camiseta mostarda gasta, jeans, botas de borracha pretas, pele morena, cabelo
# preto curto e o muiraquitã. Rodar a partir da raiz do repositório, em três passos: a pele, a importação e o modelo
# (data/models/nate.tres), que aponta para a pele:
#   godot --headless --path game -s res://tools/models/make_nate_skin.gd
#   godot --headless --path game --import
#   godot --headless --path game -s res://tools/models/make_nate_skin.gd -- --model

const SKIN_PATH := "res://assets/textures/nate_skin.png"
const MODEL_PATH := "res://data/models/nate.tres"
const ATLAS := Vector2i(64, 64)

const SKIN := Color("8a5a3c")
const SKIN_SHADE := Color("7a4e34")
const SKIN_DARK := Color("6a432c")
const SKIN_LIGHT := Color("9a6646")
const HAIR := Color("1b1714")
const HAIR_LIGHT := Color("332a24")
const EYE_WHITE := Color("efe9df")
const EYE := Color("3a2416")
const BROW := Color("2a1d16")
const MOUTH := Color("5e3026")
const MUSTARD := Color("c9a33b")
const MUSTARD_DARK := Color("a8862c")
const MUSTARD_LIGHT := Color("dcbd5e")
const BELT := Color("4a3420")
const BUCKLE := Color("b8a060")
const JEANS := Color("3b5b92")
const JEANS_DARK := Color("2e4874")
const JEANS_LIGHT := Color("4f71a8")
const BOOTS := Color("222222")
const BOOTS_LIGHT := Color("363636")
const SOLE := Color("555555")
const JADE := Color("00a86b")
const JADE_LIGHT := Color("4fd8a0")


func _initialize() -> void:
	var boxes := _boxes()
	_place_regions(boxes)
	if "--model" in OS.get_cmdline_user_args():
		var model := ModelData.new()
		model.boxes = boxes
		model.texture = load(SKIN_PATH)
		print(MODEL_PATH, ": ", error_string(ResourceSaver.save(model, MODEL_PATH)))
	else:
		var image := Image.create_empty(ATLAS.x, ATLAS.y, false, Image.FORMAT_RGBA8)
		for box in boxes:
			if box.size == Vector3i.ZERO:
				continue
			var rects := box.face_rects()
			for face: int in rects:
				var rect: Rect2i = rects[face]
				for v in rect.size.y:
					for u in rect.size.x:
						image.set_pixel(rect.position.x + u, rect.position.y + v, _paint(box.name, face, u, v, rect.size.x, rect.size.y))
		print(SKIN_PATH, ": ", error_string(image.save_png(ProjectSettings.globalize_path(SKIN_PATH))))
	quit()


# As mesmas partes e os mesmos nomes do Nate de antes (as animações e as mãos continuam valendo), sem a caixa do
# cabelo: o cabelo é pintado na cabeça.
func _boxes() -> Array[BoxData]:
	var boxes: Array[BoxData] = [
		_box(&"root", &"", Vector3i.ZERO, Vector3(0, 16, 0), Vector3(0, 16, 0)),
		_box(&"body", &"root", Vector3i(8, 12, 4), Vector3(-4, 12, -2), Vector3(0, 12, 0)),
		_box(&"muiraquita", &"body", Vector3i(2, 2, 1), Vector3(-1, 20, -3), Vector3(0, 12, 0)),
		_box(&"head", &"body", Vector3i(8, 8, 8), Vector3(-4, 24, -4), Vector3(0, 24, 0)),
		_box(&"arm_r", &"body", Vector3i(4, 4, 4), Vector3(4, 20, -2), Vector3(6, 22, 0)),
		_box(&"forearm_r", &"arm_r", Vector3i(4, 8, 4), Vector3(4, 12, -2), Vector3(6, 22, 0)),
		_box(&"arm_l", &"body", Vector3i(4, 4, 4), Vector3(-8, 20, -2), Vector3(-6, 22, 0)),
		_box(&"forearm_l", &"arm_l", Vector3i(4, 8, 4), Vector3(-8, 12, -2), Vector3(-6, 22, 0)),
		_box(&"leg_r", &"root", Vector3i(4, 7, 4), Vector3(0, 5, -2), Vector3(2, 12, 0)),
		_box(&"boot_r", &"leg_r", Vector3i(4, 5, 4), Vector3(0, 0, -2), Vector3(2, 5, 0)),
		_box(&"leg_l", &"root", Vector3i(4, 7, 4), Vector3(-4, 5, -2), Vector3(-2, 12, 0)),
		_box(&"boot_l", &"leg_l", Vector3i(4, 5, 4), Vector3(-4, 0, -2), Vector3(-2, 5, 0)),
		_box(&"hand_r", &"forearm_r", Vector3i.ZERO, Vector3(6, 13, 0), Vector3(6, 13, 0)),
		_box(&"hand_l", &"forearm_l", Vector3i.ZERO, Vector3(-6, 13, 0), Vector3(-6, 13, 0)),
		_box(&"muiraquita_chip", &"body", Vector3i.ONE, Vector3(1, 21, -3), Vector3(0, 12, 0)),
	]
	return boxes


func _box(box_name: StringName, parent: StringName, size: Vector3i, position: Vector3, pivot: Vector3) -> BoxData:
	var box := BoxData.new()
	box.name = box_name
	box.parent = parent
	box.size = size
	box.position = position
	box.pivot = pivot
	box.color = MUSTARD
	return box


# Cada caixa ganha uma região só dela na pele, lado a lado e em fileiras.
func _place_regions(boxes: Array[BoxData]) -> void:
	var cursor := Vector2i.ZERO
	var row_height := 0
	for box in boxes:
		if box.size == Vector3i.ZERO:
			continue
		var need := Vector2i(2 * box.size.z + 2 * box.size.x, box.size.z + box.size.y)
		if cursor.x + need.x > ATLAS.x:
			cursor = Vector2i(0, cursor.y + row_height)
			row_height = 0
		box.texture_offset = cursor
		cursor.x += need.x
		row_height = maxi(row_height, need.y)


func _paint(part: StringName, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		&"head":
			return _head(face, u, v, w)
		&"body":
			return _body(face, u, v, w, h)
		&"arm_r", &"arm_l":
			return _sleeve(face, u, v, h)
		&"forearm_r", &"forearm_l":
			return _forearm(face, u, v, h)
		&"leg_r", &"leg_l":
			return _leg(face, u, v, w)
		&"boot_r", &"boot_l":
			return _boot(face, v, h)
	# O muiraquitã e a lasca: jade, com um ponto mais claro.
	return JADE_LIGHT if face == BoxData.Face.FRONT and u == 0 and v == 0 else JADE


# Cabeça de 8 × 8 × 8: cabelo curto em cima, dos lados (mais comprido atrás) e na nuca; na frente, a franja, as
# sobrancelhas, os olhos, o nariz e a boca.
func _head(face: int, u: int, v: int, w: int) -> Color:
	if face == BoxData.Face.TOP:
		return HAIR_LIGHT if (u * 3 + v * 5) % 7 == 0 else HAIR
	if face == BoxData.Face.BOTTOM:
		return SKIN_DARK
	if face == BoxData.Face.BACK:
		if v < 6:
			return HAIR_LIGHT if (u * 5 + v * 3) % 9 == 0 else HAIR
		return SKIN_SHADE if v == 6 else SKIN_DARK
	if face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT:
		# A frente fica do lado de dentro de cada face lateral (as faces são vistas de fora).
		var toward_back := u < w / 2 if face == BoxData.Face.RIGHT else u >= w / 2
		if v < 2 or (toward_back and v < 6):
			return HAIR_LIGHT if (u + v * 3) % 7 == 0 else HAIR
		if v == 4 and (u == w / 2 or u == w / 2 - 1):
			return SKIN_DARK
		return SKIN_SHADE if v == 7 else SKIN
	var rows := [
		"HHHHHHHH",
		"HhHHHHhH",
		"HSHHSSSH",
		"SbbSSbbS",
		"SWESSEWS",
		"SSSnnSSS",
		"SSmmmmSS",
		"sSSSSSSs",
	]
	var palette := {"H": HAIR, "h": HAIR_LIGHT, "S": SKIN, "s": SKIN_SHADE, "b": BROW, "W": EYE_WHITE, "E": EYE,
		"n": SKIN_DARK, "m": MOUTH}
	return palette[rows[v][u]]


# Camiseta mostarda gasta, com a gola mostrando o pescoço na frente, uns fios mais claros e o cinto embaixo.
func _body(face: int, u: int, v: int, w: int, h: int) -> Color:
	if face == BoxData.Face.TOP:
		return MUSTARD_LIGHT if (u + v) % 5 == 0 else MUSTARD
	if face == BoxData.Face.BOTTOM:
		return JEANS_DARK
	if v == h - 1:
		return BUCKLE if face == BoxData.Face.FRONT and (u == w / 2 or u == w / 2 - 1) else BELT
	if face == BoxData.Face.FRONT and v <= 1 and u >= 3 and u <= w - 4:
		return SKIN if v == 0 else MUSTARD_DARK
	if face == BoxData.Face.FRONT and v == 0 and (u == 2 or u == w - 3):
		return MUSTARD_DARK
	if v == h - 2:
		return MUSTARD_DARK
	if (u * 7 + v * 3) % 17 == 0:
		return MUSTARD_LIGHT
	if (u * 5 + v * 11) % 23 == 0:
		return MUSTARD_DARK
	return MUSTARD


# Manga curta: a camiseta no alto do braço, com a barra mais escura.
func _sleeve(face: int, u: int, v: int, h: int) -> Color:
	if face == BoxData.Face.BOTTOM:
		return SKIN
	if face == BoxData.Face.TOP:
		return MUSTARD_LIGHT if u == 0 else MUSTARD
	if v == h - 1:
		return MUSTARD_DARK
	return MUSTARD_LIGHT if (u + v * 3) % 7 == 0 else MUSTARD


# Antebraço e mão: a pele, um pouco mais escura embaixo (a mão) e no lado de dentro.
func _forearm(face: int, u: int, v: int, h: int) -> Color:
	if face == BoxData.Face.BOTTOM:
		return SKIN_DARK
	if face == BoxData.Face.TOP:
		return SKIN
	if v >= h - 2:
		return SKIN_SHADE
	if face == BoxData.Face.BACK or (u == 0 and face == BoxData.Face.LEFT):
		return SKIN_SHADE
	return SKIN_LIGHT if v == 0 else SKIN


# Calça jeans: a costura dos lados, o joelho mais claro na frente e a barra escura em cima das botas.
func _leg(face: int, u: int, v: int, w: int) -> Color:
	if face == BoxData.Face.TOP:
		return JEANS
	if face == BoxData.Face.BOTTOM:
		return JEANS_DARK
	if v == 6:
		return JEANS_DARK
	if face == BoxData.Face.FRONT and v == 3 and u > 0 and u < w - 1:
		return JEANS_LIGHT
	if (face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT) and u == w / 2:
		return JEANS_DARK
	return JEANS


# Bota de borracha: a boca do cano mais clara e a sola cinza.
func _boot(face: int, v: int, h: int) -> Color:
	if face == BoxData.Face.BOTTOM or v == h - 1:
		return SOLE
	if face == BoxData.Face.TOP or v == 0:
		return BOOTS_LIGHT
	return BOOTS
