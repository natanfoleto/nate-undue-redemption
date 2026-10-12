@tool
class_name BoxData
extends Resource
## Uma caixa de um modelo blocado. Medidas em pixels, no espaço do modelo: 16 px = 1 bloco,
## o chão em y = 0 e a frente do modelo virada para -z (a frente do Godot).
##
## A textura segue o molde de caixa do Minecraft: a partir de [member texture_offset], a caixa
## ocupa uma região de (2 × profundidade + 2 × largura) por (profundidade + altura) pixels,
## com as faces direita, frente, esquerda e trás embaixo, e cima e baixo em cima.

enum Face { RIGHT, FRONT, LEFT, BACK, TOP, BOTTOM }

## 10-arte-audio: 16 px por bloco em tudo.
const PIXELS_PER_BLOCK := 16.0

const FACE_NORMALS: Dictionary[Face, Vector3] = {
	Face.RIGHT: Vector3.RIGHT,
	Face.FRONT: Vector3.FORWARD,
	Face.LEFT: Vector3.LEFT,
	Face.BACK: Vector3.BACK,
	Face.TOP: Vector3.UP,
	Face.BOTTOM: Vector3.DOWN,
}

## Nome da parte, usado pelas animações e como pai de outras caixas.
@export var name: StringName:
	set(value):
		name = value
		resource_name = value # Mostra o nome na lista do inspetor.
		emit_changed()
## Caixa à qual esta se prende e com a qual gira; vazio prende na raiz do modelo.
@export var parent: StringName:
	set(value):
		parent = value
		emit_changed()
## Largura (x), altura (y) e profundidade (z). Tamanho zero faz uma caixa vazia, só um ponto de giro para agrupar partes.
@export var size := Vector3i.ONE:
	set(value):
		size = value
		emit_changed()
## Canto de menor x, y e z.
@export var position := Vector3.ZERO:
	set(value):
		position = value
		emit_changed()
## Ponto de giro da parte.
@export var pivot := Vector3.ZERO:
	set(value):
		pivot = value
		emit_changed()
## Canto superior esquerdo da região da caixa na textura. Cada caixa precisa de uma região só dela,
## também nas caixas lisas: regiões sobrepostas trocam as cores.
@export var texture_offset := Vector2i.ZERO:
	set(value):
		texture_offset = value
		emit_changed()
## Cor da caixa lisa, usada enquanto o modelo não tem textura.
@export var color := Color.WHITE:
	set(value):
		color = value
		emit_changed()


## Região de cada face na textura, em pixels.
func face_rects() -> Dictionary[Face, Rect2i]:
	var w := size.x
	var h := size.y
	var d := size.z
	var u := texture_offset.x
	var v := texture_offset.y
	return {
		Face.RIGHT: Rect2i(u, v + d, d, h),
		Face.FRONT: Rect2i(u + d, v + d, w, h),
		Face.LEFT: Rect2i(u + d + w, v + d, d, h),
		Face.BACK: Rect2i(u + 2 * d + w, v + d, w, h),
		Face.TOP: Rect2i(u + d, v, w, d),
		Face.BOTTOM: Rect2i(u + d + w, v, w, d),
	}


## Malha da caixa em blocos, com o ponto de giro na origem.
func build_mesh(texture_size: Vector2) -> ArrayMesh:
	var low := (position - pivot) / PIXELS_PER_BLOCK
	var high := low + Vector3(size) / PIXELS_PER_BLOCK
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var rects := face_rects()
	for face: Face in FACE_NORMALS:
		var start := vertices.size()
		vertices.append_array(_face_corners(face, low, high))
		var rect := Rect2(rects[face])
		uvs.append_array([
			rect.position / texture_size,
			Vector2(rect.end.x, rect.position.y) / texture_size,
			rect.end / texture_size,
			Vector2(rect.position.x, rect.end.y) / texture_size,
		])
		for i in 4:
			normals.append(FACE_NORMALS[face])
		# Sentido horário visto de fora: a frente do triângulo no Godot.
		indices.append_array([start, start + 1, start + 2, start, start + 2, start + 3])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


# Cantos da face na ordem da textura (superior esquerdo, superior direito, inferior direito,
# inferior esquerdo), vistos de fora. Os lados se veem de pé; o topo, com a frente embaixo;
# a base, com a frente em cima.
static func _face_corners(face: Face, low: Vector3, high: Vector3) -> PackedVector3Array:
	match face:
		Face.RIGHT:
			return [Vector3(high.x, high.y, high.z), Vector3(high.x, high.y, low.z), Vector3(high.x, low.y, low.z), Vector3(high.x, low.y, high.z)]
		Face.FRONT:
			return [Vector3(high.x, high.y, low.z), Vector3(low.x, high.y, low.z), Vector3(low.x, low.y, low.z), Vector3(high.x, low.y, low.z)]
		Face.LEFT:
			return [Vector3(low.x, high.y, low.z), Vector3(low.x, high.y, high.z), Vector3(low.x, low.y, high.z), Vector3(low.x, low.y, low.z)]
		Face.BACK:
			return [Vector3(low.x, high.y, high.z), Vector3(high.x, high.y, high.z), Vector3(high.x, low.y, high.z), Vector3(low.x, low.y, high.z)]
		Face.TOP:
			return [Vector3(high.x, high.y, high.z), Vector3(low.x, high.y, high.z), Vector3(low.x, high.y, low.z), Vector3(high.x, high.y, low.z)]
		_:
			return [Vector3(high.x, low.y, low.z), Vector3(low.x, low.y, low.z), Vector3(low.x, low.y, high.z), Vector3(high.x, low.y, high.z)]
