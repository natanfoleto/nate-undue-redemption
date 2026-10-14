extends SceneTree
# Pinta a pele dos mobs no molde das skins do Minecraft, como a de Nate, sem mudar as caixas (as animações continuam
# valendo): o pelo do lobo, os ossos do esqueleto com o brilho roxo nas juntas, o manto do necromante e a pedra do
# golem com as rachaduras. As variantes usam a mesma pintura com as cores delas (10-arte-audio). Rodar a partir da
# raiz do repositório, em três passos: as peles, a importação e os modelos, que passam a apontar para elas:
#   godot --headless --path game -s res://tools/models/make_mob_skins.gd
#   godot --headless --path game --import
#   godot --headless --path game -s res://tools/models/make_mob_skins.gd -- --model

const MODELS := "res://data/models/"
const SKINS := "res://assets/textures/"
const ATLAS_WIDTH := 128

# Cores de cada modelo: base, escura, clara e as próprias de cada família.
const LOOKS := {
	"wolf": {"family": "wolf", "base": "4b4f55", "dark": "3b3e43", "light": "5d6168", "belly": "6c7076",
		"muzzle": "7c8086", "nose": "151515", "ear": "5a4444", "stripe": "33363a", "eye": "e0a030"},
	"wolf_alpha": {"family": "wolf", "base": "1c1d20", "dark": "121315", "light": "2a2c30", "belly": "34363b",
		"muzzle": "3e4045", "nose": "080808", "ear": "3a2a2a", "stripe": "3c3f45", "eye": "ffc23a"},
	"skeleton": {"family": "skeleton", "base": "5c5d63", "dark": "46474c", "light": "74757b", "gap": "26262b",
		"glow": "b060ff", "metal": "8d8f94", "metal_light": "c4c6cc", "wood": "5a3b22"},
	"skeleton_veteran": {"family": "skeleton", "base": "2a2a2e", "dark": "1c1c20", "light": "3c3c42", "gap": "0e0e11",
		"glow": "e090ff", "metal": "6d6f74", "metal_light": "a4a6ac", "wood": "4a2f1a"},
	"necromancer": {"family": "necromancer", "base": "3a2148", "dark": "2a1636", "light": "4a2c5a", "trim": "6a2a90",
		"skin": "6a5a70", "skin_dark": "554760", "face": "0c0a10", "wood": "4a3a2a", "wood_dark": "382a1e",
		"stone": "9a50e0", "stone_light": "c890ff"},
	"necromancer_elder": {"family": "necromancer", "base": "141018", "dark": "0c0a10", "light": "201a26", "trim": "6a2a90",
		"skin": "6a5a70", "skin_dark": "554760", "face": "0c0a10", "wood": "4a3a2a", "wood_dark": "382a1e",
		"stone": "9a50e0", "stone_light": "c890ff"},
	"golem": {"family": "golem", "base": "7a7a80", "dark": "5a5a60", "light": "8e8e95", "mortar": "4a4a50",
		"crack": "a050e0", "crack_light": "c890ff"},
	"golem_elder": {"family": "golem", "base": "3a3a40", "dark": "2a2a30", "light": "4a4a52", "mortar": "1e1e24",
		"crack": "c070ff", "crack_light": "e0b0ff"},
}

var _look: Dictionary


func _initialize() -> void:
	var write_models := "--model" in OS.get_cmdline_user_args()
	for model_name: String in LOOKS:
		_look = LOOKS[model_name]
		var path := MODELS + model_name + ".tres"
		var model := load(path) as ModelData
		var height := _place_regions(model.boxes)
		var skin_path := SKINS + model_name + "_skin.png"
		if write_models:
			model.texture = load(skin_path)
			print(path, ": ", error_string(ResourceSaver.save(model, path)))
			continue
		var image := Image.create_empty(ATLAS_WIDTH, height, false, Image.FORMAT_RGBA8)
		for box in model.boxes:
			if box.size == Vector3i.ZERO:
				continue
			var rects := box.face_rects()
			for face: int in rects:
				var rect: Rect2i = rects[face]
				for v in rect.size.y:
					for u in rect.size.x:
						var color := _paint(box, face, u, v, rect.size.x, rect.size.y)
						image.set_pixel(rect.position.x + u, rect.position.y + v, color)
		print(skin_path, ": ", error_string(image.save_png(ProjectSettings.globalize_path(skin_path))))
	quit()


# Cada caixa ganha uma região só dela, lado a lado e em fileiras; devolve a altura da pele.
func _place_regions(boxes: Array[BoxData]) -> int:
	var cursor := Vector2i.ZERO
	var row_height := 0
	for box in boxes:
		if box.size == Vector3i.ZERO:
			continue
		var need := Vector2i(2 * box.size.z + 2 * box.size.x, box.size.z + box.size.y)
		if cursor.x + need.x > ATLAS_WIDTH:
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


func _paint(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match _look.family:
		"wolf":
			return _wolf(box, face, u, v, w, h)
		"skeleton":
			return _skeleton(box, face, u, v, w, h)
		"necromancer":
			return _necromancer(box, face, u, v, w, h)
	return _golem(box, face, u, v, w, h)


# Pelo: a cor base em mechas mais claras e mais escuras.
func _fur(box: BoxData, face: int, u: int, v: int) -> Color:
	var n := _noise(box, face, u, v)
	if n < 0.14:
		return _c("dark")
	if n > 0.88:
		return _c("light")
	return _c("base")


# Lobo: o lombo com a faixa escura no meio, a barriga e o focinho mais claros, o nariz escuro, a orelha por dentro
# e as patas e a ponta do rabo mais claras.
func _wolf(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	var side := face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT
	match box.name:
		&"body":
			if face == BoxData.Face.TOP:
				return _c("stripe") if u == w / 2 or u == w / 2 - 1 else _fur(box, face, u, v)
			if face == BoxData.Face.BOTTOM:
				return _c("belly")
			if v >= h - 2 and (side or face == BoxData.Face.FRONT):
				return _c("belly") if v == h - 1 else _c("light")
			if face == BoxData.Face.FRONT and v >= 2:
				return _c("light") if _noise(box, face, u, v, 1) < 0.5 else _c("belly")
			return _fur(box, face, u, v)
		&"head":
			if face == BoxData.Face.TOP:
				return _c("stripe") if u == w / 2 or u == w / 2 - 1 else _fur(box, face, u, v)
			if face == BoxData.Face.FRONT:
				# A testa escura em cima dos olhos e a bochecha clara embaixo.
				if v == 2:
					return _c("dark")
				return _c("muzzle") if v >= 4 else _fur(box, face, u, v)
			if side:
				var front := u >= w - 2 if face == BoxData.Face.RIGHT else u <= 1
				return _c("muzzle") if v >= h - 2 and front else _fur(box, face, u, v)
			return _fur(box, face, u, v)
		&"snout":
			if face == BoxData.Face.FRONT:
				if v == 0 and u >= 1 and u <= w - 2:
					return _c("nose")
				return _c("dark") if v == h - 1 else _c("muzzle")
			if face == BoxData.Face.BOTTOM:
				return _c("belly")
			if face == BoxData.Face.TOP:
				var tip := v >= h - 1
				return _c("nose") if tip and u >= 1 and u <= w - 2 else _c("muzzle")
			return _c("dark") if v == h - 1 else _c("muzzle")
		&"ear_r", &"ear_l":
			if face == BoxData.Face.FRONT:
				return _c("ear") if v == h - 1 else _c("dark")
			return _c("dark")
		&"eye_r", &"eye_l":
			return _c("eye")
		&"tail":
			# A ponta do rabo (atrás, +z) mais clara.
			var tip := false
			if face == BoxData.Face.TOP or face == BoxData.Face.BOTTOM:
				tip = v <= 1 if face == BoxData.Face.TOP else v >= h - 2
			elif face == BoxData.Face.RIGHT:
				tip = u <= 1
			elif face == BoxData.Face.LEFT:
				tip = u >= w - 2
			elif face == BoxData.Face.BACK:
				tip = true
			return _c("belly") if tip else _fur(box, face, u, v)
	# Patas: o pelo descendo até a pata mais clara, com as unhas escuras na frente.
	if face == BoxData.Face.BOTTOM:
		return _c("dark")
	if v == h - 1:
		return _c("nose") if face == BoxData.Face.FRONT and u % 2 == 0 else _c("belly")
	return _fur(box, face, u, v)


# Osso: a cor base com rachaduras finas mais escuras e pontos mais claros.
func _bone(box: BoxData, face: int, u: int, v: int) -> Color:
	var n := _noise(box, face, u, v)
	if n < 0.08:
		return _c("dark")
	if n > 0.9:
		return _c("light")
	return _c("base")


# Esqueleto: o crânio com as órbitas, o nariz e os dentes; as costelas com o esterno e a coluna; os ossos dos braços
# e das pernas com as juntas brilhando em roxo; a espada com o pomo, o cabo de couro, a guarda e a lâmina de dois fios.
func _skeleton(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"head":
			if face == BoxData.Face.FRONT:
				var rows := [
					"BBBBBBBB",
					"BBBBBBBB",
					"BGGBBGGB",
					"BGGBBGGB",
					"BBBGGBBB",
					"BBBBBBBB",
					"BgBgBgBB",
					"DBDBDBDD",
				]
				var palette := {"B": _bone(box, face, u, v), "G": _c("gap"), "g": _c("gap"), "D": _c("dark")}
				return palette[rows[v][u]]
			if face == BoxData.Face.BOTTOM:
				return _c("gap")
			return _bone(box, face, u, v)
		&"body":
			if face == BoxData.Face.FRONT or face == BoxData.Face.BACK:
				# As costelas em faixas, com o vão escuro entre elas e o esterno (ou a coluna) no meio.
				if u == w / 2 or u == w / 2 - 1:
					return _c("dark") if face == BoxData.Face.BACK else _c("light")
				return _bone(box, face, u, v) if v % 2 == 1 else _c("gap")
			if face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT:
				return _bone(box, face, u, v) if v % 2 == 1 else _c("gap")
			return _c("dark")
		&"pelvis":
			if face == BoxData.Face.FRONT and v == 0 and (u == 1 or u == w - 2):
				return _c("gap")
			return _bone(box, face, u, v)
		&"spine":
			return _c("dark") if v % 2 == 0 else _c("base")
		&"core", &"eye_r", &"eye_l":
			return _c("glow")
		&"arm_r", &"arm_l", &"leg_r", &"leg_l":
			# Junta no meio (cotovelo, joelho) e no alto, brilhando; a mão e o pé mais escuros embaixo.
			if face != BoxData.Face.TOP and face != BoxData.Face.BOTTOM:
				if v == h / 2 or v == 0:
					return _c("glow") if u == 0 else _c("light")
				if v >= h - 2:
					return _c("dark")
			return _bone(box, face, u, v)
		&"blade", &"tip":
			# Lâmina de dois fios: os fios claros em cima e embaixo e a canaleta escura no meio, na lateral.
			if face == BoxData.Face.TOP or face == BoxData.Face.BOTTOM:
				return _c("metal_light")
			if face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT:
				return _c("metal").darkened(0.18) if v == 0 and box.name == &"blade" else _c("metal")
			return _c("metal_light")
		&"guard", &"pommel":
			# Ferro escuro, com as pontas da guarda mais claras.
			var edge := face != BoxData.Face.TOP and face != BoxData.Face.BOTTOM and (u == 0 or u == w - 1)
			return _c("metal").darkened(0.15) if edge else _c("metal").darkened(0.45)
	# O cabo, enrolado em couro.
	return _c("wood").darkened(0.25) if (u + v) % 2 == 0 else _c("wood")


# Pano do manto: dobras verticais mais escuras e uns fios mais claros.
func _cloth(box: BoxData, face: int, u: int, v: int) -> Color:
	if face != BoxData.Face.TOP and face != BoxData.Face.BOTTOM and u % 3 == 2:
		return _c("dark")
	return _c("light") if _noise(box, face, u, v) > 0.9 else _c("base")


# Necromante: o manto com dobras, a barra e a faixa roxas e marcas na barra; o capuz com a borda clara em volta do
# rosto em sombra; as mangas com o punho roxo; as mãos pálidas; o cajado com anéis e a pedra com uma face clara.
func _necromancer(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"robe":
			if face == BoxData.Face.BOTTOM:
				return _c("dark")
			if face != BoxData.Face.TOP:
				if v == h - 1:
					return _c("trim")
				if v == h - 3 and u % 4 == 1:
					return _c("trim")
			return _cloth(box, face, u, v)
		&"body":
			if face == BoxData.Face.FRONT:
				# A gola em V e a faixa na cintura.
				if v <= 2 and absi(u * 2 + 1 - w) <= (3 - v) * 2:
					return _c("trim")
				if v == h - 2:
					return _c("trim")
			if v == h - 2 and face != BoxData.Face.TOP and face != BoxData.Face.BOTTOM:
				return _c("trim")
			return _cloth(box, face, u, v)
		&"hood":
			if face == BoxData.Face.FRONT:
				# A abertura do rosto fica atrás da caixa do rosto; em volta dela, a borda mais clara.
				if v >= 1 and v <= 6 and u >= 1 and u <= w - 2:
					return _c("light") if v == 1 or u == 1 or u == w - 2 else _c("face")
				return _c("base")
			if face == BoxData.Face.TOP:
				return _c("dark") if u == w / 2 or u == w / 2 - 1 else _cloth(box, face, u, v)
			return _cloth(box, face, u, v)
		&"face":
			return _c("face").lightened(0.06) if v == h - 1 else _c("face")
		&"eye_r", &"eye_l":
			return _c("stone_light")
		&"arm_r", &"arm_l":
			if face != BoxData.Face.TOP and face != BoxData.Face.BOTTOM and v == h - 1:
				return _c("trim")
			return _cloth(box, face, u, v)
		&"hand_r", &"hand_l":
			return _c("skin_dark") if v == h - 1 or face == BoxData.Face.BOTTOM else _c("skin")
		&"staff":
			if face == BoxData.Face.TOP or face == BoxData.Face.BOTTOM:
				return _c("wood_dark")
			if v >= 2 and v <= 4:
				return _c("trim")
			return _c("wood_dark") if v % 5 == 0 else _c("wood")
		&"stone":
			return _c("stone_light") if (u + v) % 3 == 0 else _c("stone")
	# As faixas roxas do Ancião (barra, frente e capuz).
	return _c("trim").lightened(0.15) if (u + v) % 4 == 0 else _c("trim")


# Pedra: blocos com a junta escura (fileiras de 4 pixels, juntas desencontradas), manchas e uns veios roxos.
func _stone(box: BoxData, face: int, u: int, v: int) -> Color:
	var row := v / 4
	var joint_v := v % 4 == 3
	var joint_u := (u + (row % 2) * 3) % 6 == 5
	if joint_v or joint_u:
		return _c("mortar")
	var n := _noise(box, face, u, v)
	if n < 0.012:
		return _c("crack")
	if n < 0.1:
		return _c("dark")
	if n > 0.9:
		return _c("light")
	return _c("base")


# Golem: tudo de pedra; a cabeça com a testa saliente escura e a boca em fenda; os punhos com os nós dos dedos; as
# rachaduras roxas com um ponto mais claro.
func _golem(box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	match box.name:
		&"head":
			if face == BoxData.Face.FRONT:
				if v <= 1:
					return _c("mortar") if v == 1 else _c("dark")
				if v == h - 2 and u >= 2 and u <= w - 3:
					return _c("mortar")
			return _stone(box, face, u, v)
		&"fist_r", &"fist_l":
			if face == BoxData.Face.FRONT and v <= 2:
				return _c("light") if u % 2 == 0 and v == 1 else _c("mortar") if v == 2 else _c("base")
			return _stone(box, face, u, v)
		&"eye_r", &"eye_l":
			return _c("crack_light")
		&"crack_1", &"crack_2", &"crack_3", &"crack_4":
			return _c("crack_light") if (u + v) % 4 == 0 else _c("crack")
	return _stone(box, face, u, v)
