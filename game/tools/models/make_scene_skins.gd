extends SceneTree
# Pinta a pele das cenas (10-arte-audio) no molde das skins do Minecraft, como a de Nate e a dos mobs: o herói
# antigo e o irmão, refeitos com as caixas de Nate (cabeça de 8 × 8 × 8, braços de 4; as animações continuam
# valendo); a cabeça da Boiúna, com as escamas; e o santuário e o cogumelo de esporos, que também estão no jogo e
# mantêm as caixas. Rodar a partir da raiz do repositório, em três passos: as peles, a importação e os modelos, que
# passam a apontar para elas:
#   godot --headless --path game -s res://tools/models/make_scene_skins.gd
#   godot --headless --path game --import
#   godot --headless --path game -s res://tools/models/make_scene_skins.gd -- --model

const MODELS := "res://data/models/"
const SKINS := "res://assets/textures/"

# O herói: túnica cor de urucum com a faixa creme e os traços pretos, a tanga de algodão, a faixa vermelha na
# cabeça, o cabelo comprido, os traços de jenipapo nos antebraços e o muiraquitã inteiro. O irmão: túnica escura
# com a faixa ocre, cabelo curto, a testa franzida, o olhar de lado e uma cicatriz na bochecha.
const PEOPLE := {
	"hero": {"skin": "7a4a2c", "skin_shade": "6a3f25", "skin_dark": "5a3420", "skin_light": "8c5836",
		"hair": "141210", "hair_light": "2a2420", "band": "b33a22", "band_dark": "8a2a18", "mark": "1a1410",
		"cloth": "b5562f", "cloth_dark": "93452a", "cloth_light": "c76a40", "trim": "e8d9b0", "trim_dark": "c9b98f",
		"wrap": "e8d9b0", "wrap_dark": "c9b98f", "cord": "b33a22", "sole": "3a2a20", "eye": "3a2416",
		"eye_white": "efe9df", "brow": "1a1410", "mouth": "5e3026", "jade": "00a86b", "jade_light": "4fd8a0",
		"long_hair": true, "amulet": true},
	"brother": {"skin": "7a4a2c", "skin_shade": "6a3f25", "skin_dark": "5a3420", "skin_light": "8c5836",
		"hair": "141210", "hair_light": "2a2420", "band": "a8752e", "band_dark": "7a5420", "mark": "1a1410",
		"cloth": "2a2018", "cloth_dark": "1c1610", "cloth_light": "3a2e22", "trim": "a8752e", "trim_dark": "7a5420",
		"wrap": "4a3a2a", "wrap_dark": "3a2c1f", "cord": "a8752e", "sole": "2a1e16", "eye": "2a1a10",
		"eye_white": "e6ddd0", "brow": "0e0a08", "mouth": "4e2820", "scar": "a87058",
		"long_hair": false, "amulet": false},
}
const PEOPLE_ATLAS := Vector2i(64, 64)
# Modelos que mantêm as caixas: só a pele muda.
const PROPS := ["boiuna_head", "sanctuary", "spore_mushroom"]
const PROPS_WIDTH := 128

const FRONT := BoxData.Face.FRONT
const BACK := BoxData.Face.BACK
const RIGHT := BoxData.Face.RIGHT
const LEFT := BoxData.Face.LEFT
const TOP := BoxData.Face.TOP
const BOTTOM := BoxData.Face.BOTTOM

var _look: Dictionary


func _initialize() -> void:
	var write_models := "--model" in OS.get_cmdline_user_args()
	for model_name: String in PEOPLE:
		_look = PEOPLE[model_name]
		var boxes := _person_boxes()
		_place_regions(boxes, PEOPLE_ATLAS.x)
		_finish(model_name, boxes, PEOPLE_ATLAS, write_models, null)
	for model_name: String in PROPS:
		_look = {}
		var model := load(MODELS + model_name + ".tres") as ModelData
		var height := _place_regions(model.boxes, PROPS_WIDTH)
		_finish(model_name, model.boxes, Vector2i(PROPS_WIDTH, height), write_models, model)
	quit()


# Primeiro passo: pinta a pele. Segundo: grava o modelo (o mesmo, nos que mantêm as caixas) apontando para ela.
func _finish(model_name: String, boxes: Array[BoxData], atlas: Vector2i, write_model: bool, model: ModelData) -> void:
	var skin_path := SKINS + model_name + "_skin.png"
	if write_model:
		if model == null:
			model = ModelData.new()
			model.boxes = boxes
		model.texture = load(skin_path)
		var path := MODELS + model_name + ".tres"
		print(path, ": ", error_string(ResourceSaver.save(model, path)))
		return
	var image := Image.create_empty(atlas.x, atlas.y, false, Image.FORMAT_RGBA8)
	for box in boxes:
		if box.size == Vector3i.ZERO:
			continue
		var rects := box.face_rects()
		for face: int in rects:
			var rect: Rect2i = rects[face]
			for v in rect.size.y:
				for u in rect.size.x:
					var color := _paint(model_name, box, face, u, v, rect.size.x, rect.size.y)
					image.set_pixel(rect.position.x + u, rect.position.y + v, color)
	print(skin_path, ": ", error_string(image.save_png(ProjectSettings.globalize_path(skin_path))))


# As caixas e os nomes de Nate (as animações valem para os dois); o muiraquitã só no herói.
func _person_boxes() -> Array[BoxData]:
	var boxes: Array[BoxData] = [
		_box(&"root", &"", Vector3i.ZERO, Vector3(0, 16, 0), Vector3(0, 16, 0), "cloth"),
		_box(&"body", &"root", Vector3i(8, 12, 4), Vector3(-4, 12, -2), Vector3(0, 12, 0), "cloth"),
		_box(&"head", &"body", Vector3i(8, 8, 8), Vector3(-4, 24, -4), Vector3(0, 24, 0), "skin"),
		_box(&"arm_r", &"body", Vector3i(4, 4, 4), Vector3(4, 20, -2), Vector3(6, 22, 0), "cloth"),
		_box(&"forearm_r", &"arm_r", Vector3i(4, 8, 4), Vector3(4, 12, -2), Vector3(6, 22, 0), "skin"),
		_box(&"arm_l", &"body", Vector3i(4, 4, 4), Vector3(-8, 20, -2), Vector3(-6, 22, 0), "cloth"),
		_box(&"forearm_l", &"arm_l", Vector3i(4, 8, 4), Vector3(-8, 12, -2), Vector3(-6, 22, 0), "skin"),
		_box(&"leg_r", &"root", Vector3i(4, 7, 4), Vector3(0, 5, -2), Vector3(2, 12, 0), "wrap"),
		_box(&"boot_r", &"leg_r", Vector3i(4, 5, 4), Vector3(0, 0, -2), Vector3(2, 5, 0), "skin"),
		_box(&"leg_l", &"root", Vector3i(4, 7, 4), Vector3(-4, 5, -2), Vector3(-2, 12, 0), "wrap"),
		_box(&"boot_l", &"leg_l", Vector3i(4, 5, 4), Vector3(-4, 0, -2), Vector3(-2, 5, 0), "skin"),
		_box(&"hand_r", &"forearm_r", Vector3i.ZERO, Vector3(6, 13, 0), Vector3(6, 13, 0), "skin"),
		_box(&"hand_l", &"forearm_l", Vector3i.ZERO, Vector3(-6, 13, 0), Vector3(-6, 13, 0), "skin"),
	]
	if _look.amulet:
		boxes.insert(2, _box(&"muiraquita", &"body", Vector3i(2, 2, 1), Vector3(-1, 20, -3), Vector3(0, 12, 0), "jade"))
		boxes.append(_box(&"muiraquita_chip", &"body", Vector3i.ONE, Vector3(1, 21, -3), Vector3(0, 12, 0), "jade"))
	return boxes


func _box(box_name: StringName, parent: StringName, size: Vector3i, position: Vector3, pivot: Vector3,
		color_key: String) -> BoxData:
	var box := BoxData.new()
	box.name = box_name
	box.parent = parent
	box.size = size
	box.position = position
	box.pivot = pivot
	box.color = _c(color_key)
	return box


# Cada caixa ganha uma região só dela, lado a lado e em fileiras; devolve a altura da pele.
func _place_regions(boxes: Array[BoxData], width: int) -> int:
	var cursor := Vector2i.ZERO
	var row_height := 0
	for box in boxes:
		if box.size == Vector3i.ZERO:
			continue
		var need := Vector2i(2 * box.size.z + 2 * box.size.x, box.size.z + box.size.y)
		if cursor.x + need.x > width:
			cursor = Vector2i(0, cursor.y + row_height)
			row_height = 0
		box.texture_offset = cursor
		cursor.x += need.x
		row_height = maxi(row_height, need.y)
	return cursor.y + row_height


func _c(key: String) -> Color:
	return Color(_look[key])


# Número fixo e sem padrão de cada pixel de cada face, de 0 a 1.
func _noise(box: BoxData, face: int, u: int, v: int, salt := 0) -> float:
	return float(absi(hash([String(box.name), face, u, v, salt])) % 1000) / 1000.0


func _paint(model_name: String, box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match model_name:
		"boiuna_head":
			return _boiuna(box, face, u, v, w, h)
		"sanctuary":
			return _sanctuary(box, face, u, v, w, h)
		"spore_mushroom":
			return _mushroom(box, face, u, v, w, h)
	return _person(box, face, u, v, w, h)


# --- Pessoas ---

func _person(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"head":
			return _head(box, face, u, v, w)
		&"body":
			return _tunic(box, face, u, v, w, h)
		&"arm_r", &"arm_l":
			return _sleeve(box, face, u, v, h)
		&"forearm_r", &"forearm_l":
			return _forearm(face, v, h)
		&"leg_r", &"leg_l":
			return _wrap(box, face, u, v, w, h)
		&"boot_r", &"boot_l":
			return _shin(face, v, h)
	# O muiraquitã e a lasca: jade, com um ponto mais claro.
	return _c("jade_light") if face == FRONT and u == 0 and v == 0 else _c("jade")


func _hair(box: BoxData, face: int, u: int, v: int) -> Color:
	return _c("hair_light") if _noise(box, face, u, v) < 0.12 else _c("hair")


# Cabeça de 8 × 8 × 8. O herói tem a faixa vermelha com pontos pretos e o cabelo comprido, emoldurando o rosto e
# caindo atrás; o irmão, o cabelo curto com franja, a testa franzida, o olhar de lado e a cicatriz.
func _head(box: BoxData, face: int, u: int, v: int, w: int) -> Color:
	var long_hair: bool = _look.long_hair
	if face == TOP:
		return _hair(box, face, u, v)
	if face == BOTTOM:
		return _c("hair") if long_hair and v >= w - 3 else _c("skin_dark")
	if long_hair and v == 1:
		var knot := face == BACK and (u == w / 2 or u == w / 2 - 1)
		if knot:
			return _c("band_dark")
		return _c("mark") if face == FRONT and (u == 2 or u == 5) else _c("band")
	if face == BACK:
		if long_hair or v < 6:
			return _hair(box, face, u, v)
		return _c("skin_shade") if v == 6 else _c("skin_dark")
	if face == RIGHT or face == LEFT:
		# A frente fica do lado de dentro de cada face lateral (as faces são vistas de fora).
		var toward_back := u < w / 2 if face == RIGHT else u >= w / 2
		var near_front := u >= w - 2 if face == RIGHT else u <= 1
		if v == 0 or (long_hair and not near_front) or (not long_hair and (v < 2 or (toward_back and v < 6))):
			return _hair(box, face, u, v)
		if v == 4 and (u == w / 2 or u == w / 2 - 1):
			return _c("skin_dark")
		return _c("skin_shade") if v == 7 else _c("skin")
	var rows: Array = [
		"HHHHHHHH",
		"RRRRRRRR",
		"HSSSSSSH",
		"HbbSSbbH",
		"HWESSEWH",
		"HSSnnSSH",
		"HSmmmmSH",
		"HsSSSSsH",
	] if long_hair else [
		"HHHHHHHH",
		"HhHHHHhH",
		"SbSHHSbS",
		"SSbSSbSS",
		"SWESSWES",
		"SSSnnScS",
		"SSSmmScS",
		"sSSSSSSs",
	]
	var palette := {"H": _c("hair"), "h": _c("hair_light"), "S": _c("skin"), "s": _c("skin_shade"),
		"b": _c("brow"), "W": _c("eye_white"), "E": _c("eye"), "n": _c("skin_dark"), "m": _c("mouth"),
		"R": _c("band"), "c": _c("scar" if _look.has("scar") else "skin")}
	return palette[(rows[v] as String)[u]]


# Túnica: a gola mostrando o pescoço na frente, as dobras, a faixa creme (ou ocre) com os traços pretos em degraus
# e a barra com pontos. O cabelo comprido do herói cai nas costas.
func _tunic(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	if face == TOP:
		return _c("cloth")
	if face == BOTTOM:
		return _c("wrap_dark")
	if face == BACK and _look.long_hair and v <= 2 and u >= 1 and u <= w - 2:
		return _hair(box, face, u, v)
	if face == FRONT and v == 0:
		return _c("skin") if u >= 3 and u <= w - 4 else _c("cloth_dark")
	if v == 7 or v == 10:
		return _c("cloth_dark")
	if v == 8:
		return _c("mark") if posmod(u, 4) == 0 else _c("trim")
	if v == 9:
		return _c("mark") if posmod(u, 4) == 2 else _c("trim")
	if v == h - 1:
		return _c("trim") if posmod(u, 3) == 1 else _c("cloth_dark")
	var n := _noise(box, face, u, v)
	if n < 0.1:
		return _c("cloth_dark")
	return _c("cloth_light") if n > 0.9 else _c("cloth")


# Manga curta da túnica, com a barra clara.
func _sleeve(box: BoxData, face: int, u: int, v: int, h: int) -> Color:
	if face == BOTTOM:
		return _c("skin")
	if face == TOP:
		return _c("cloth")
	if v == h - 1:
		return _c("trim")
	return _c("cloth_light") if _noise(box, face, u, v) > 0.88 else _c("cloth")


# Antebraço e mão: a pulseira no alto e, no herói, os traços de jenipapo; a mão um pouco mais escura.
func _forearm(face: int, v: int, h: int) -> Color:
	if face == BOTTOM:
		return _c("skin_dark")
	if face == TOP:
		return _c("skin")
	if v == 0:
		return _c("cord")
	if _look.long_hair and (v == 2 or v == 4):
		return _c("mark")
	if v >= h - 2:
		return _c("skin_shade")
	return _c("skin_light") if v == 1 else _c("skin")


# Tanga de algodão: as dobras, a costura dos lados e a barra com a linha da cor da faixa.
func _wrap(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	if face == TOP:
		return _c("wrap")
	if face == BOTTOM:
		return _c("skin_shade")
	if v == h - 1:
		return _c("wrap_dark")
	if v == h - 2:
		return _c("band")
	if (face == RIGHT or face == LEFT) and u == w / 2:
		return _c("wrap_dark")
	return _c("wrap_dark") if _noise(box, face, u, v) < 0.12 else _c("wrap")


# Canela e pé descalço: a sombra da tanga em cima, o cordão no tornozelo e a sola escura.
func _shin(face: int, v: int, h: int) -> Color:
	if face == BOTTOM:
		return _c("sole")
	if face == TOP:
		return _c("skin")
	if v == 0:
		return _c("skin_shade")
	if v == h - 3:
		return _c("cord")
	return _c("skin_dark") if v == h - 1 else _c("skin")


# --- A cabeça da Boiúna ---

const SCALE := Color("141018")
const SCALE_ALT := Color("1c1422")
const SCALE_EDGE := Color("0a080d")
const SCALE_SHINE := Color("2c2038")
const BELLY := Color("3a2e44")
const BELLY_LINE := Color("261e2e")
const SHEEN := Color("5a2a80")
const SHEEN_LIGHT := Color("8a50b0")
const BOIUNA_EYE := Color("f2a030")
const BOIUNA_EYE_LIGHT := Color("ffd070")
const PUPIL := Color("1a0e00")
const FANG := Color("e8e0c8")


# Escamas em fileiras encaixadas, cada uma com a borda escura embaixo e um brilho no alto; a barriga em placas;
# os olhos cor de âmbar com a pupila em fenda; as narinas e as presas na frente da cabeça.
func _boiuna(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"eye_r", &"eye_l":
			var slit := (face == RIGHT or face == LEFT) and u == w / 2
			if slit:
				return PUPIL
			return BOIUNA_EYE_LIGHT if v == 0 else BOIUNA_EYE
		&"sheen":
			if face == TOP:
				return SHEEN_LIGHT if u == w / 2 or u == w / 2 - 1 else SHEEN
			return SHEEN
		&"jaw":
			if face == BOTTOM:
				return BELLY_LINE if posmod(v, 3) == 2 else BELLY
			if face == FRONT and v == 0:
				return BELLY
			return _scales(box, face, u, v)
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
	if face == BOTTOM:
		return BELLY_LINE if posmod(v, 3) == 2 else BELLY
	return _scales(box, face, u, v)


func _scales(box: BoxData, face: int, u: int, v: int) -> Color:
	var row := v / 3
	var along := u + (row % 2) * 2
	var local := Vector2i(posmod(along, 4), posmod(v, 3))
	if local.y == 2 or local.x == 0:
		return SCALE_EDGE if local.y == 2 else SCALE
	if local.y == 0 and local.x == 1:
		return SCALE_SHINE
	var scale_id := hash([String(box.name), face, floori(along / 4.0), row])
	return SCALE_ALT if absi(scale_id) % 3 == 0 else SCALE


# --- O santuário ---

const STONE := Color("5a5550")
const STONE_DARK := Color("45413c")
const STONE_LIGHT := Color("6c665f")
const STEP_STONE := Color("6a645c")
const MOSS := Color("4a5a3a")
const PILLAR := Color("8a7a66")
const PILLAR_DARK := Color("6a5c4c")
const PILLAR_LIGHT := Color("9c8c76")
const RED := Color("b5402a")
const RED_DARK := Color("8a2e1e")
const CREAM := Color("e8d9b0")
const BLACK := Color("1d1a17")
const ASH := Color("2a2622")
const JADE := Color("3fae8a")
const JADE_LIGHT := Color("8fe8c8")
const JADE_DARK := Color("2a7a60")


# Base e degrau de blocos de pedra com juntas e musgo; o pilar com o losango entalhado no meio; as faixas vermelha
# e preta com pontos creme; a bacia com cinza no fundo; e o cristal de jade com as facetas.
func _sanctuary(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"base", &"step":
			var base := STONE if box.name == &"base" else STEP_STONE
			var joint := posmod(u, 8) == 7 or ((face == TOP or face == BOTTOM) and posmod(v, 8) == 7)
			if joint:
				return STONE_DARK
			if face != TOP and face != BOTTOM and v == 0:
				return STONE_LIGHT
			var n := _noise(box, face, u, v)
			if n < 0.04:
				return MOSS
			if n > 0.92:
				return STONE_LIGHT
			var block := Vector2i(u / 8, v / 8)
			return base.darkened(0.06) if absi(hash([String(box.name), face, block])) % 3 == 0 else base
		&"pillar":
			if face == TOP or face == BOTTOM:
				return PILLAR_DARK
			if u == 0 or u == w - 1:
				return PILLAR_DARK
			if v >= 3 and v <= h - 4:
				var zig := 1 + absi(posmod(v - 3, 8) - 4)
				if u == zig or u == w - 1 - zig:
					return PILLAR_DARK
			return PILLAR_LIGHT if _noise(box, face, u, v) > 0.9 else PILLAR
		&"band_red":
			if v == 0 and face != TOP and face != BOTTOM:
				return CREAM if posmod(u, 3) == 1 else RED
			return RED_DARK if face == BOTTOM else RED
		&"band_black":
			return CREAM if face != TOP and face != BOTTOM and posmod(u, 4) == 1 else BLACK
		&"bowl":
			if face == TOP:
				var inside := u >= 2 and u < w - 2 and v >= 2 and v < h - 2
				return ASH if inside else STONE_LIGHT
			if v == 0:
				return STONE_LIGHT
			return STEP_STONE
		&"glow":
			if u == v or u == v + 1:
				return JADE_LIGHT
			return JADE_DARK if u + v >= w + h - 4 else JADE
	return STONE


# --- O cogumelo de esporos ---

const STEM := Color("d8d2c0")
const STEM_DARK := Color("c2baa6")
const STEM_LIGHT := Color("efe9da")
const SOIL := Color("8a7a60")
const CAP := Color("2fc4c0")
const CAP_DARK := Color("1f9c99")
const CAP_TOP := Color("6fe8d8")
const CAP_SPOT := Color("c8fff4")
const GILL := Color("1a6e6c")
const GILL_LIGHT := Color("2a8e8a")


# O pé com fibras, o anel e a terra embaixo; o chapéu com pintas claras e a borda escura; as lamelas por baixo.
func _mushroom(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"stem":
			if face == TOP or face == BOTTOM:
				return STEM_DARK
			if v >= h - 2:
				return SOIL
			if v == 2:
				return STEM_LIGHT
			if v == 3:
				return STEM_DARK
			if u == 1:
				return STEM_LIGHT
			return STEM_DARK if _noise(box, face, u, v) < 0.15 else STEM
		&"cap":
			if face == BOTTOM:
				# Lamelas saindo do meio, como raios.
				var angle := atan2(v + 0.5 - h / 2.0, u + 0.5 - w / 2.0)
				return GILL_LIGHT if floori((angle + PI) / TAU * 16.0) % 2 == 0 else GILL
			if face != TOP and v == h - 1:
				return CAP_DARK
			return CAP_SPOT if _noise(box, face, u, v) < 0.07 else CAP
		&"cap_top":
			return CAP_SPOT if _noise(box, face, u, v) < 0.1 else CAP_TOP
	return Color.WHITE if u == 0 and v == 0 else CAP_SPOT
