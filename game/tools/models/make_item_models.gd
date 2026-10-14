extends SceneTree
# Refaz os modelos dos itens com mais forma e a textura pintada (16 px por bloco, no molde das skins do Minecraft):
# as armas com lâmina, fio, ponta, guarda e cabo; os projéteis; as armaduras com costuras, rebites e os padrões
# marajoara; a poção, as melhorias, o Selo e o pergaminho. O item na mão aponta para a frente (−z), com a mão na
# origem. Rodar a partir da raiz do repositório, em três passos: as texturas, a importação e os modelos:
#   godot --headless --path game -s res://tools/models/make_item_models.gd
#   godot --headless --path game --import
#   godot --headless --path game -s res://tools/models/make_item_models.gd -- --model

const MODELS := "res://data/models/"
const TEXTURES := "res://assets/textures/items/"
const ATLAS_WIDTH := 64

const STEEL := Color("b8bcc2")
const STEEL_DARK := Color("8a8e95")
const STEEL_EDGE := Color("e8eaee")
const IRON := Color("6e7178")
const IRON_DARK := Color("4a4c52")
const IRON_LIGHT := Color("9a9ea6")
const WOOD := Color("6b4a2b")
const WOOD_DARK := Color("4e3520")
const WOOD_LIGHT := Color("86603a")
const PALE_WOOD := Color("a87a42")
const PALE_WOOD_DARK := Color("86602f")
const LEATHER := Color("3a2618")
const LEATHER_LIGHT := Color("54382a")
const JADE := Color("3fae8a")
const JADE_DARK := Color("1f7a5a")
const JADE_LIGHT := Color("8fe0c0")
const STONE := Color("8fa79a")
const STONE_DARK := Color("6a7e72")
const STONE_LIGHT := Color("b4c8bc")
const RED := Color("b5402a")
const RED_DARK := Color("85301f")
const BLACK := Color("1d1a17")
const CREAM := Color("e8d9b0")
const TERRACOTTA := Color("b5562f")
const TERRACOTTA_DARK := Color("8e4324")
const ORANGE := Color("c8702a")
const ORANGE_DARK := Color("9a5520")
const YELLOW := Color("f2d040")
const FIBER := Color("c8963c")
const FIBER_DARK := Color("a07428")
const RUBBER := Color("6a2820")
const GLASS := Color("cfe8ec")
const LIQUID := Color("c4283a")
const LIQUID_DARK := Color("8e1a28")
const LIQUID_LIGHT := Color("ff8a94")
const CORK := Color("a0703a")
const PAPER := Color("e8d9b0")
const PEDESTAL := Color("6a645c")
const PEDESTAL_DARK := Color("554f48")
const PEBBLE := Color("8a8f96")


func _initialize() -> void:
	var write_models := "--model" in OS.get_cmdline_user_args()
	var shapes := _shapes()
	for item_name: String in shapes:
		var boxes: Array[BoxData] = []
		boxes.assign(shapes[item_name])
		var height := _place_regions(boxes)
		var texture_path := TEXTURES + item_name + ".png"
		if write_models:
			var model := ModelData.new()
			model.boxes = boxes
			model.texture = load(texture_path)
			print(MODELS + item_name + ".tres: ", error_string(ResourceSaver.save(model, MODELS + item_name + ".tres")))
			continue
		var image := Image.create_empty(ATLAS_WIDTH, height, false, Image.FORMAT_RGBA8)
		for box in boxes:
			var rects := box.face_rects()
			for face: int in rects:
				var rect: Rect2i = rects[face]
				for v in rect.size.y:
					for u in rect.size.x:
						image.set_pixel(rect.position.x + u, rect.position.y + v, _paint(item_name, box, face, u, v, rect.size.x, rect.size.y))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEXTURES))
		print(texture_path, ": ", error_string(image.save_png(ProjectSettings.globalize_path(texture_path))))
	quit()


# As caixas de cada item, em pixels: largura (x), altura (y) e comprimento (z), e o canto de menor x, y e z.
func _shapes() -> Dictionary:
	return {
		"machete": [
			_b("grip", Vector3i(1, 2, 5), Vector3(-0.5, -1, -2)),
			_b("pommel", Vector3i(1, 2, 1), Vector3(-0.5, -1, 3)),
			_b("bolster", Vector3i(2, 3, 1), Vector3(-1, -1.5, -3)),
			_b("blade", Vector3i(1, 3, 10), Vector3(-0.5, -1, -13)),
			_b("tip", Vector3i(1, 2, 2), Vector3(-0.5, 0, -15)),
			_b("point", Vector3i(1, 1, 1), Vector3(-0.5, 1, -16)),
		],
		"pickaxe": [
			_b("handle", Vector3i(1, 1, 13), Vector3(-0.5, -0.5, -12)),
			_b("socket", Vector3i(2, 3, 3), Vector3(-1, -1.5, -15)),
			_b("arm_r", Vector3i(4, 2, 2), Vector3(1, -1, -14.5)),
			_b("arm_l", Vector3i(4, 2, 2), Vector3(-5, -1, -14.5)),
			_b("tip_r", Vector3i(2, 1, 2), Vector3(5, -1.5, -14.5)),
			_b("tip_l", Vector3i(2, 1, 2), Vector3(-7, -1.5, -14.5)),
		],
		"spear": [
			_b("shaft", Vector3i(1, 1, 22), Vector3(-0.5, -0.5, -18)),
			_b("band_red", Vector3i(2, 2, 1), Vector3(-1, -1, -6)),
			_b("band_black", Vector3i(2, 2, 1), Vector3(-1, -1, -9)),
			_b("jade", Vector3i(2, 2, 1), Vector3(-1, -1, -18)),
			_b("head_base", Vector3i(2, 1, 2), Vector3(-1, -0.5, -20)),
			_b("head_mid", Vector3i(3, 1, 3), Vector3(-1.5, -0.5, -23)),
			_b("head_tip", Vector3i(2, 1, 1), Vector3(-1, -0.5, -24)),
			_b("head_point", Vector3i(1, 1, 1), Vector3(-0.5, -0.5, -25)),
		],
		"tacape": [
			_b("handle", Vector3i(1, 2, 9), Vector3(-0.5, -1, -7)),
			_b("head_1", Vector3i(2, 3, 3), Vector3(-1, -1.5, -10)),
			_b("head_2", Vector3i(2, 4, 3), Vector3(-1, -2, -13)),
			_b("head_3", Vector3i(2, 5, 4), Vector3(-1, -2.5, -17)),
			_b("head_end", Vector3i(2, 3, 1), Vector3(-1, -1.5, -18)),
		],
		"stone_blade": [
			_b("grip", Vector3i(1, 2, 4), Vector3(-0.5, -1, -2)),
			_b("binding", Vector3i(2, 3, 1), Vector3(-1, -1.5, -3)),
			_b("blade", Vector3i(1, 3, 6), Vector3(-0.5, -1.5, -9)),
			_b("tip", Vector3i(1, 2, 2), Vector3(-0.5, -1, -11)),
			_b("point", Vector3i(1, 1, 1), Vector3(-0.5, -0.5, -12)),
		],
		"slingshot": [
			_b("handle", Vector3i(1, 1, 4), Vector3(-0.5, -0.5, -3)),
			_b("fork", Vector3i(5, 1, 1), Vector3(-2.5, -0.5, -4)),
			_b("prong_r", Vector3i(1, 1, 3), Vector3(1.5, -0.5, -7)),
			_b("prong_l", Vector3i(1, 1, 3), Vector3(-2.5, -0.5, -7)),
			_b("band", Vector3i(3, 1, 1), Vector3(-1.5, -0.5, -7)),
		],
		"blowgun": [
			_b("tube", Vector3i(2, 2, 20), Vector3(-1, -1, -16)),
			_b("ring_red", Vector3i(3, 3, 1), Vector3(-1.5, -1.5, -12)),
			_b("ring_cream", Vector3i(3, 3, 1), Vector3(-1.5, -1.5, -6)),
			_b("mouth", Vector3i(3, 3, 1), Vector3(-1.5, -1.5, 3)),
		],
		"javelin": [
			_b("shaft", Vector3i(1, 1, 18), Vector3(-0.5, -0.5, -12)),
			_b("band", Vector3i(2, 2, 1), Vector3(-1, -1, -2)),
			_b("head_base", Vector3i(2, 1, 1), Vector3(-1, -0.5, -13)),
			_b("head_mid", Vector3i(3, 1, 2), Vector3(-1.5, -0.5, -15)),
			_b("head_tip", Vector3i(2, 1, 1), Vector3(-1, -0.5, -16)),
			_b("head_point", Vector3i(1, 1, 1), Vector3(-0.5, -0.5, -17)),
		],
		"bow": [
			_b("grip", Vector3i(1, 3, 1), Vector3(-0.5, -1.5, -3)),
			_b("jade", Vector3i(2, 1, 1), Vector3(-1, 1.5, -3)),
			_b("limb_r1", Vector3i(3, 1, 1), Vector3(0.5, -0.5, -3)),
			_b("limb_r2", Vector3i(3, 1, 1), Vector3(3.5, -0.5, -2.5)),
			_b("tip_r", Vector3i(1, 1, 2), Vector3(6.5, -0.5, -1.5)),
			_b("limb_l1", Vector3i(3, 1, 1), Vector3(-3.5, -0.5, -3)),
			_b("limb_l2", Vector3i(3, 1, 1), Vector3(-6.5, -0.5, -2.5)),
			_b("tip_l", Vector3i(1, 1, 2), Vector3(-7.5, -0.5, -1.5)),
			_b("string", Vector3i(14, 1, 1), Vector3(-7, -0.5, 0.5)),
		],
		"stone": [
			_b("stone", Vector3i(3, 3, 3), Vector3(-1.5, -1.5, -1.5)),
		],
		"dart": [
			_b("point", Vector3i(1, 1, 1), Vector3(-0.5, -0.5, -4)),
			_b("shaft", Vector3i(1, 1, 7), Vector3(-0.5, -0.5, -3)),
			_b("tuft", Vector3i(2, 2, 2), Vector3(-1, -1, 3)),
		],
		"arrow": [
			_b("shaft", Vector3i(1, 1, 10), Vector3(-0.5, -0.5, -5)),
			_b("head_base", Vector3i(3, 1, 1), Vector3(-1.5, -0.5, -6)),
			_b("head_point", Vector3i(1, 1, 2), Vector3(-0.5, -0.5, -8)),
			_b("fletch_v", Vector3i(1, 3, 3), Vector3(-0.5, -1.5, 3)),
			_b("fletch_h", Vector3i(3, 1, 3), Vector3(-1.5, -0.5, 3)),
		],
		"miner_vest": [
			_b("vest", Vector3i(10, 9, 5), Vector3(-5, 2, -2.5)),
			_b("pocket_r", Vector3i(3, 2, 1), Vector3(1, 4, -3)),
			_b("pocket_l", Vector3i(3, 2, 1), Vector3(-4, 4, -3)),
		],
		"miner_armor": [
			_b("body", Vector3i(11, 11, 6), Vector3(-5.5, 0, -3)),
			_b("plate", Vector3i(8, 3, 1), Vector3(-4, 6, -3.5)),
			_b("belt", Vector3i(11, 1, 6), Vector3(-5.5, 1, -3.2)),
			_b("shoulder_r", Vector3i(4, 3, 6), Vector3(3, 9, -3)),
			_b("shoulder_l", Vector3i(4, 3, 6), Vector3(-7, 9, -3)),
		],
		"fiber_cloak": [
			_b("cape", Vector3i(10, 13, 1), Vector3(-5, -3, 2)),
			_b("stripe_1", Vector3i(10, 1, 1), Vector3(-5, 7, 3)),
			_b("stripe_2", Vector3i(10, 1, 1), Vector3(-5, 3, 3)),
			_b("stripe_3", Vector3i(10, 1, 1), Vector3(-5, -1, 3)),
			_b("shoulder_r", Vector3i(3, 2, 5), Vector3(3, 10, -2.5)),
			_b("shoulder_l", Vector3i(3, 2, 5), Vector3(-6, 10, -2.5)),
			_b("collar", Vector3i(6, 1, 1), Vector3(-3, 11, -3)),
		],
		"cuirass": [
			_b("plates", Vector3i(10, 10, 6), Vector3(-5, 1, -3)),
			_b("stripe_1", Vector3i(10, 1, 1), Vector3(-5, 3, -3.5)),
			_b("stripe_2", Vector3i(10, 1, 1), Vector3(-5, 6, -3.5)),
			_b("stripe_3", Vector3i(10, 1, 1), Vector3(-5, 9, -3.5)),
			_b("shoulder_r", Vector3i(4, 3, 6), Vector3(3, 9, -3)),
			_b("shoulder_l", Vector3i(4, 3, 6), Vector3(-7, 9, -3)),
		],
		"potion": [
			_b("liquid", Vector3i(6, 6, 6), Vector3(-3, -5, -3)),
			_b("glass", Vector3i(4, 1, 4), Vector3(-2, 1, -2)),
			_b("neck", Vector3i(2, 2, 2), Vector3(-1, 2, -1)),
			_b("cork", Vector3i(3, 2, 3), Vector3(-1.5, 4, -1.5)),
		],
		"heart_bead": [
			_b("top_r", Vector3i(2, 2, 2), Vector3(1, 3, -1)),
			_b("top_l", Vector3i(2, 2, 2), Vector3(-3, 3, -1)),
			_b("middle", Vector3i(6, 2, 2), Vector3(-3, 1, -1)),
			_b("low", Vector3i(4, 1, 2), Vector3(-2, 0, -1)),
			_b("tip", Vector3i(2, 1, 2), Vector3(-1, -1, -1)),
		],
		"charge_bead": [
			_b("tip", Vector3i(2, 2, 2), Vector3(-1, 4, -1)),
			_b("body", Vector3i(4, 3, 2), Vector3(-2, 1, -1)),
			_b("bottom", Vector3i(2, 1, 2), Vector3(-1, 0, -1)),
		],
		"seal": [
			_b("chip", Vector3i(3, 3, 2), Vector3(-1.5, -1.5, -1)),
		],
		"scroll": [
			_b("pedestal", Vector3i(12, 12, 12), Vector3(-6, 0, -6)),
			_b("top", Vector3i(14, 2, 14), Vector3(-7, 12, -7)),
			_b("roll", Vector3i(10, 3, 3), Vector3(-5, 14, -1.5)),
			_b("band_red", Vector3i(1, 4, 4), Vector3(-3, 13.5, -2)),
			_b("band_black", Vector3i(1, 4, 4), Vector3(2, 13.5, -2)),
		],
	}


func _b(box_name: String, size: Vector3i, position: Vector3) -> BoxData:
	var box := BoxData.new()
	box.name = StringName(box_name)
	box.size = size
	box.position = position
	return box


# Cada caixa ganha uma região só dela, lado a lado e em fileiras; devolve a altura da textura.
func _place_regions(boxes: Array[BoxData]) -> int:
	var cursor := Vector2i.ZERO
	var row_height := 0
	for box in boxes:
		var need := Vector2i(2 * box.size.z + 2 * box.size.x, box.size.z + box.size.y)
		if cursor.x + need.x > ATLAS_WIDTH:
			cursor = Vector2i(0, cursor.y + row_height)
			row_height = 0
		box.texture_offset = cursor
		cursor.x += need.x
		row_height = maxi(row_height, need.y)
	return cursor.y + row_height


func _noise(box: BoxData, face: int, u: int, v: int, salt := 0) -> float:
	return float(absi(hash([String(box.name), face, u, v, salt])) % 1000) / 1000.0


func _side(face: int) -> bool:
	return face == BoxData.Face.RIGHT or face == BoxData.Face.LEFT


func _cap(face: int) -> bool:
	return face == BoxData.Face.TOP or face == BoxData.Face.BOTTOM


# Madeira: veios escuros ao longo do comprimento e uns pontos mais claros.
func _wood(box: BoxData, face: int, u: int, v: int, base := WOOD, dark := WOOD_DARK, light := WOOD_LIGHT) -> Color:
	var n := _noise(box, face, u, v)
	if n < 0.18:
		return dark
	if n > 0.92:
		return light
	return base


func _paint(item: String, box: BoxData, face: int, u: int, v: int, w: int, h: int) -> Color:
	var part := String(box.name)
	match item:
		"machete":
			return _machete(box, part, face, u, v, w, h)
		"pickaxe":
			return _pickaxe(box, part, face, u, v, w, h)
		"spear", "javelin":
			return _spear(box, part, face, u, v, w, h)
		"tacape":
			return _tacape(box, part, face, u, v, w, h)
		"stone_blade":
			return _stone_blade(box, part, face, u, v, w, h)
		"slingshot":
			return _slingshot(box, part, face, u, v, w, h)
		"blowgun":
			return _blowgun(box, part, face, u, v, w, h)
		"bow":
			return _bow(box, part, face, u, v, w, h)
		"stone":
			var n := _noise(box, face, u, v)
			return PEBBLE.darkened(0.25) if n < 0.25 else PEBBLE.lightened(0.15) if n > 0.85 else PEBBLE
		"dart":
			if part == "point":
				return IRON_DARK
			if part == "tuft":
				return RED.lightened(0.2) if (u + v) % 2 == 0 else RED
			return CREAM.darkened(0.1) if v % 3 == 0 else CREAM
		"arrow":
			if part.begins_with("head"):
				return STONE_LIGHT if _cap(face) and face == BoxData.Face.TOP else STONE
			if part.begins_with("fletch"):
				return CREAM if (u + v) % 3 == 0 else RED
			return _wood(box, face, u, v, PALE_WOOD, PALE_WOOD_DARK, PALE_WOOD.lightened(0.15))
		"miner_vest":
			return _vest(box, part, face, u, v, w, h)
		"miner_armor":
			return _miner_armor(box, part, face, u, v, w, h)
		"fiber_cloak":
			return _cloak(box, part, face, u, v, w, h)
		"cuirass":
			return _cuirass(box, part, face, u, v, w, h)
		"potion":
			return _potion(box, part, face, u, v, w, h)
		"heart_bead", "charge_bead", "seal":
			if part == "tip" and item == "heart_bead":
				return JADE_DARK
			if part == "bottom":
				return JADE_DARK
			return JADE_LIGHT if (u == 0 and v == 0) or _noise(box, face, u, v) > 0.93 else JADE
		"scroll":
			return _scroll(box, part, face, u, v, w, h)
	return Color.MAGENTA


# Facão: o cabo de madeira com dois rebites, o anel de metal e a lâmina com o dorso escuro em cima, o fio claro
# embaixo e uns riscos; a ponta sobe em degraus.
func _machete(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"grip":
			if _side(face) and v == 0 and (u == 1 or u == w - 2):
				return IRON_LIGHT
			return _wood(box, face, u, v)
		"pommel":
			return WOOD_DARK
		"bolster":
			return IRON_LIGHT if face == BoxData.Face.TOP else IRON_DARK
	if face == BoxData.Face.TOP:
		return STEEL_DARK
	if face == BoxData.Face.BOTTOM:
		return STEEL_EDGE
	if _side(face):
		if v == h - 1:
			return STEEL_EDGE
		if v == 0:
			return STEEL_DARK
		return STEEL.darkened(0.12) if _noise(box, face, u, v) < 0.12 else STEEL
	return STEEL


# Picareta: o cabo com a empunhadura de couro atrás; a cabeça de ferro, clara em cima e escura embaixo, com as
# pontas mais claras.
func _pickaxe(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	if part == "handle":
		var grip := false
		if _side(face):
			grip = u <= 3 if face == BoxData.Face.RIGHT else u >= w - 4
		elif _cap(face):
			grip = v <= 3 if face == BoxData.Face.TOP else v >= h - 4
		if grip:
			return LEATHER_LIGHT if (u + v) % 2 == 0 else LEATHER
		return _wood(box, face, u, v)
	if part.begins_with("tip"):
		return IRON_LIGHT if face == BoxData.Face.TOP else IRON
	if face == BoxData.Face.TOP:
		return IRON_LIGHT
	if face == BoxData.Face.BOTTOM:
		return IRON_DARK
	if part == "socket":
		return IRON_DARK if _side(face) and (v == 0 or v == h - 1) else IRON
	return IRON.darkened(0.15) if _noise(box, face, u, v) < 0.15 else IRON


# Lança e azagaia: a haste de madeira com o padrão marajoara pintado em espiral, as faixas e a ponta de pedra em folha,
# com o veio de jade no meio.
func _spear(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"shaft":
			var along := u if _side(face) else v
			if along % 6 == 0:
				return BLACK
			if along % 6 == 3:
				return RED
			return _wood(box, face, u, v, PALE_WOOD, PALE_WOOD_DARK, PALE_WOOD.lightened(0.15))
		"band", "band_red":
			return CREAM if (u + v) % 3 == 0 else RED
		"band_black":
			return CREAM if (u + v) % 3 == 0 else BLACK
		"jade":
			return JADE_LIGHT if u == 0 and v == 0 else JADE
	# A ponta: a pedra com o veio de jade no meio, em cima; as bordas mais escuras.
	if face == BoxData.Face.TOP:
		if part == "head_mid" and u == w / 2:
			return JADE
		return STONE_DARK if u == 0 or u == w - 1 else STONE_LIGHT
	if face == BoxData.Face.BOTTOM:
		return STONE_DARK
	return STONE


# Tacape marajoara: o cabo achatado com a amarração vermelha e a cabeça larga de madeira escura, com o padrão
# marajoara em degraus (preto, vermelho e creme) nos lados.
func _tacape(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	if part == "handle":
		var along := u if _side(face) else v
		var wrap := false
		if face == BoxData.Face.RIGHT:
			wrap = u <= 3
		elif face == BoxData.Face.LEFT:
			wrap = u >= w - 4
		elif face == BoxData.Face.TOP:
			wrap = v <= 3
		if wrap:
			return CREAM if along % 2 == 0 else RED
		return _wood(box, face, u, v, Color("6b4226"), Color("4f301a"), Color("7e5232"))
	if _side(face) and (part == "head_2" or part == "head_3"):
		# Degraus marajoara: uma escada preta com o miolo vermelho e o fundo creme.
		var step := (u + v) % 4
		if v == 0 or v == h - 1:
			return BLACK
		if step == 0:
			return BLACK
		if step == 1:
			return RED
		return CREAM if part == "head_3" else Color("6b4226")
	if part == "head_end" and face == BoxData.Face.FRONT:
		return BLACK
	return _wood(box, face, u, v, Color("6b4226"), Color("4f301a"), Color("7e5232"))


# Lâmina de pedra verde: o cabo de madeira, a amarração preta com o cruzado creme e a lâmina de jade lascada, com o
# fio mais escuro e as lascas mais claras.
func _stone_blade(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"grip":
			return _wood(box, face, u, v, Color("6b4226"), Color("4f301a"), Color("7e5232"))
		"binding":
			return CREAM if (u + v) % 2 == 0 and not _cap(face) else BLACK
	if face == BoxData.Face.BOTTOM or (_side(face) and v == h - 1):
		return JADE_DARK
	if _noise(box, face, u, v) < 0.3:
		return JADE_LIGHT
	return JADE


# Estilingue: a forquilha de madeira com a casca em manchas, a empunhadura de couro e o elástico escuro entre as
# pontas.
func _slingshot(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	if part == "band":
		return RUBBER.lightened(0.15) if u == w / 2 else RUBBER
	if part == "handle":
		return LEATHER_LIGHT if (u + v) % 2 == 0 else LEATHER
	if part.begins_with("prong") and face == BoxData.Face.FRONT:
		return WOOD_LIGHT
	return _wood(box, face, u, v)


# Zarabatana: o tubo de madeira com os nós escuros a cada 5 pixels; os anéis com o padrão marajoara; a boca com o
# furo escuro.
func _blowgun(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"tube":
			var along := u if _side(face) else v
			if along % 5 == 0:
				return Color("3e2614")
			return _wood(box, face, u, v, Color("5a3a22"), Color("4a2e1a"), Color("6e4a2e"))
		"ring_red":
			return BLACK if (u + v) % 2 == 0 and not _cap(face) else RED
		"ring_cream":
			return BLACK if u == 1 or v == 1 else CREAM
	if face == BoxData.Face.BACK and u == 1 and v == 1:
		return Color("000000")
	return BLACK


# Arco marajoara: as pás de madeira com faixas pretas e vermelhas, a empunhadura vermelha com o cruzado creme, a
# corda clara e a pedra de jade.
func _bow(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"string":
			return CREAM
		"jade":
			return JADE_LIGHT if u == 0 else JADE
		"grip":
			return CREAM if (u + v) % 2 == 0 else RED
	if part.begins_with("tip"):
		return BLACK
	var along := u if not _side(face) else v
	if along % 3 == 0:
		return BLACK if part.ends_with("2") else RED
	return _wood(box, face, u, v, Color("8a5a2b"), Color("6e4620"), Color("a06c36"))


# Colete de minerador: a lona laranja com as duas faixas amarelas refletivas, o zíper escuro no meio, as costuras
# claras nas bordas e os bolsos com a tampa mais escura.
func _vest(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	if part.begins_with("pocket"):
		return ORANGE_DARK if v == 0 else ORANGE
	if face == BoxData.Face.TOP or face == BoxData.Face.BOTTOM:
		return ORANGE_DARK
	if v == 3 or v == 6:
		return YELLOW
	if face == BoxData.Face.FRONT and (u == w / 2 or u == w / 2 - 1):
		return Color("3a2a1a") if u == w / 2 - 1 else ORANGE_DARK
	if v == h - 1 or v == 0:
		return ORANGE_DARK
	return ORANGE.lightened(0.08) if _noise(box, face, u, v) > 0.9 else ORANGE


# Armadura de minerador: o couro com costuras, a placa de ferro do peito com rebites nos cantos, o cinto com a
# fivela e as ombreiras de ferro com uma fileira de rebites.
func _miner_armor(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"plate":
			if (u == 0 or u == w - 1) and (v == 0 or v == h - 1):
				return IRON_LIGHT
			return IRON.darkened(0.1) if _noise(box, face, u, v) < 0.2 else IRON
		"belt":
			if face == BoxData.Face.FRONT and (u == w / 2 or u == w / 2 - 1):
				return Color("b8a060")
			return LEATHER
		"shoulder_r", "shoulder_l":
			if face == BoxData.Face.TOP:
				return IRON_LIGHT if v % 2 == 0 and u % 2 == 0 else IRON
			return IRON_DARK if v == h - 1 else IRON
	# O couro: costura clara tracejada nas bordas.
	if not _cap(face) and (u == 0 or u == w - 1 or v == 0) and (u + v) % 2 == 0:
		return Color("8a6a4a")
	return Color("6a4a2a").darkened(0.1) if _noise(box, face, u, v) < 0.15 else Color("6a4a2a")


# Manto de fibras marajoara: a fibra trançada em diagonal, as faixas pretas e vermelhas com pontos creme e a gola
# vermelha.
func _cloak(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"stripe_1", "stripe_3":
			return CREAM if u % 3 == 1 and not _cap(face) else BLACK
		"stripe_2":
			return CREAM if u % 3 == 1 and not _cap(face) else RED
		"collar":
			return RED_DARK if v == h - 1 else RED
	return FIBER_DARK if (u + v) % 3 == 0 else FIBER


# Couraça de cerâmica marajoara: a terracota com o padrão em degraus pintado de preto na frente e atrás, as faixas
# com pontos e as ombreiras com a borda creme.
func _cuirass(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"stripe_1", "stripe_3":
			return CREAM if u % 2 == 0 and not _cap(face) else BLACK
		"stripe_2":
			return BLACK if u % 2 == 0 and not _cap(face) else CREAM
		"shoulder_r", "shoulder_l":
			if face == BoxData.Face.TOP:
				return CREAM if u == 0 or u == w - 1 or v == 0 or v == h - 1 else TERRACOTTA
			return TERRACOTTA_DARK if v == h - 1 else TERRACOTTA
	if (face == BoxData.Face.FRONT or face == BoxData.Face.BACK) and v >= 1 and v <= h - 2:
		# Degraus marajoara: linhas pretas em escada, que se refletem no meio.
		var x := u if u < w / 2 else w - 1 - u
		if (x + v) % 4 == 0:
			return BLACK
	if v == h - 1:
		return TERRACOTTA_DARK
	return TERRACOTTA.lightened(0.06) if _noise(box, face, u, v) > 0.9 else TERRACOTTA


# Poção de vida: o líquido vermelho mais claro em cima e com um reflexo do vidro, o gargalo de vidro e a rolha.
func _potion(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"glass", "neck":
			return GLASS.lightened(0.3) if u == 0 else GLASS
		"cork":
			return CORK.darkened(0.15) if (u + v) % 2 == 0 else CORK
	if face == BoxData.Face.TOP:
		return LIQUID_LIGHT
	if face == BoxData.Face.BOTTOM or v == h - 1:
		return LIQUID_DARK
	if not _cap(face) and u == 1 and v >= 1 and v <= 3:
		return Color("ffe0e4")
	return LIQUID_LIGHT if v == 0 else LIQUID


# Pergaminho no pedestal: a pedra do pedestal em blocos, o tampo com a borda escura, o rolo de papel com linhas e as
# faixas vermelha e preta.
func _scroll(box: BoxData, part: String, face: int, u: int, v: int, w: int, h: int) -> Color:
	match part:
		"roll":
			if _side(face):
				return PAPER.darkened(0.25) if (u + v) % 2 == 0 else PAPER.darkened(0.1)
			return PAPER.darkened(0.12) if v == 1 and u % 2 == 0 else PAPER
		"band_red":
			return RED
		"band_black":
			return BLACK
		"top":
			if face == BoxData.Face.TOP:
				return PEDESTAL_DARK if u == 0 or u == w - 1 or v == 0 or v == h - 1 else PEDESTAL
			return PEDESTAL_DARK
	if not _cap(face) and (v % 4 == 3 or (u + (v / 4) * 3) % 6 == 5):
		return PEDESTAL_DARK
	return PEDESTAL.lightened(0.08) if _noise(box, face, u, v) > 0.9 else PEDESTAL
