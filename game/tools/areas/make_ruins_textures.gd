extends SceneTree
# Pinta as texturas das Ruínas (10-arte-audio): a parede de tijolos de terracota lisos e o piso de placas grandes de
# pedra clara (2 por bloco, encaixadas), no jeito das texturas pintadas do pacote (32 px por bloco; cada peça com a
# borda clara em cima e à esquerda, a sombra embaixo e à direita, e as juntas escuras). Sem padrão: o marajoara fica
# nos detalhes (o Padrão de jade). As texturas se repetem sem emenda. Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_ruins_textures.gd

const SIZE := 32
const WALL_PATH := "res://assets/textures/terracotta_wall.png"
const FLOOR_PATH := "res://assets/textures/light_stone_floor.png"

const TERRACOTTA := Color("b4643e")
const TERRACOTTA_JOINT := Color("6f3b26")
const STONE := Color("cfc6b4")
const STONE_JOINT := Color("a2988a")


func _initialize() -> void:
	_save(_paint(TERRACOTTA, TERRACOTTA_JOINT, Vector2i(16, 8), 8, 0.06, 7), WALL_PATH)
	_save(_paint(STONE, STONE_JOINT, Vector2i(32, 16), 16, 0.035, 11), FLOOR_PATH)
	quit()


# Peças do tamanho dado em fileiras; cada fileira ímpar anda [param shift] pixels para o lado (tijolos encaixados).
# Cada peça tem um tom um pouco diferente, e manchas suaves e grãos dão o jeito de pintado.
func _paint(base: Color, joint: Color, piece: Vector2i, shift: int, variation: float, seed_value: int) -> Image:
	var image := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in SIZE:
		for x in SIZE:
			var row := y / piece.y
			var along := posmod(x + (row % 2) * shift, SIZE)
			var local := Vector2i(along % piece.x, y % piece.y)
			var cell := Vector2i(along / piece.x, row)
			if local.x == piece.x - 1 or local.y == piece.y - 1:
				image.set_pixel(x, y, _shade(joint, (_grain(x, y, seed_value) - 0.5) * 0.06))
				continue
			var light := (_hash(cell.x, cell.y, seed_value) - 0.5) * 2.0 * variation
			light += (_blotch(x, y, seed_value) - 0.5) * 0.08
			light += (_grain(x, y, seed_value + 1) - 0.5) * 0.05
			if local.x == 0 or local.y == 0:
				light += 0.1
			elif local.x == piece.x - 2 or local.y == piece.y - 2:
				light -= 0.12
			image.set_pixel(x, y, _shade(base, light))
	return image


static func _shade(color: Color, amount: float) -> Color:
	return color.lightened(amount) if amount >= 0.0 else color.darkened(-amount)


# Manchas: valores sorteados numa grade de 8 px, misturados entre eles e repetidos a cada 32 px.
static func _blotch(x: int, y: int, seed_value: int) -> float:
	var cells := SIZE / 8
	var at := Vector2(x, y) / 8.0
	var corner := Vector2i(floori(at.x), floori(at.y))
	var t := Vector2(smoothstep(0.0, 1.0, at.x - corner.x), smoothstep(0.0, 1.0, at.y - corner.y))
	var a := _hash(posmod(corner.x, cells), posmod(corner.y, cells), seed_value)
	var b := _hash(posmod(corner.x + 1, cells), posmod(corner.y, cells), seed_value)
	var c := _hash(posmod(corner.x, cells), posmod(corner.y + 1, cells), seed_value)
	var d := _hash(posmod(corner.x + 1, cells), posmod(corner.y + 1, cells), seed_value)
	return lerpf(lerpf(a, b, t.x), lerpf(c, d, t.x), t.y)


static func _grain(x: int, y: int, seed_value: int) -> float:
	return _hash(x, y, seed_value + 100)


static func _hash(x: int, y: int, seed_value: int) -> float:
	return float(absi(hash(Vector3i(x, y, seed_value))) % 1000) / 1000.0


func _save(image: Image, path: String) -> void:
	print(path, ": ", error_string(image.save_png(ProjectSettings.globalize_path(path))))
