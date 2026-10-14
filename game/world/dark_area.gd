class_name DarkArea
extends Node3D
## Área escura (08-mapa): sem a Luz Ancestral, Nate para na borda; com ela, a luz do muiraquitã ilumina em volta dele
## (05-itens). A escuridão é do próprio lugar: um decalque escurece o chão, as paredes e as plantas da área, com a
## borda esfumada e ondulada, e a luz de Nate clareia o que estiver perto dele. Os personagens, os objetos e os itens
## (camada de desenho 2, a dos modelos de blocos) não escurecem.

## Retângulo da área no chão, centrado no nó, em blocos.
@export var area_size := Vector2.ZERO
## Altura da escuridão acima do chão, em blocos: a do alto das paredes.
@export var cover_height := 0.0
## Os blocos escuros (um ponto por bloco, branco no escuro), com a margem em volta; e a margem, em blocos.
@export var mask: Texture2D
@export var margin := 0.0
## Quanto o lugar escurece, de 0 a 1.
@export var darkness := 0.0
## Pontos por bloco na borda da escuridão, e o tamanho (em blocos) e a força da ondulação dela.
@export var edge_resolution := 1
@export var wobble_size := 0.0
@export var wobble := 0.0
## Onde a borda esfumada começa e acaba, no valor da máscara misturada e ondulada (0 fora, 1 dentro).
@export var edge_start := 0.0
@export var edge_end := 0.0

## Só o terreno (camada de desenho 1) escurece.
const TERRAIN_LAYER := 1

var _barrier: CollisionShape3D


func _ready() -> void:
	add_to_group(&"dark_areas")
	var decal := Decal.new()
	var depth := cover_height + 0.5
	decal.size = Vector3(area_size.x + margin * 2.0, depth, area_size.y + margin * 2.0)
	# Do meio bloco abaixo do chão até o alto das paredes: pega o chão, as paredes e as plantas.
	decal.position.y = depth / 2.0 - 0.5
	decal.texture_albedo = _edge_texture()
	decal.modulate = Color(0, 0, 0, darkness)
	decal.albedo_mix = 1.0
	decal.normal_fade = 0.0
	decal.upper_fade = 0.0
	decal.lower_fade = 0.0
	decal.cull_mask = TERRAIN_LAYER
	add_child(decal)
	# Barreira (camada 4): segura quem anda até Nate ter a Luz Ancestral.
	var body := StaticBody3D.new()
	body.collision_layer = HitShape.BARRIER_LAYER
	body.collision_mask = 0
	var shape := BoxShape3D.new()
	shape.size = Vector3(area_size.x, cover_height, area_size.y)
	_barrier = CollisionShape3D.new()
	_barrier.shape = shape
	_barrier.position.y = cover_height / 2.0
	body.add_child(_barrier)
	add_child(body)


func contains(point: Vector3) -> bool:
	var offset := point - global_position
	return absf(offset.x) <= area_size.x / 2.0 and absf(offset.z) <= area_size.y / 2.0


func _process(_delta: float) -> void:
	if GameState.has_light() and not _barrier.disabled:
		_barrier.disabled = true


# A borda da escuridão: a máscara de um ponto por bloco ampliada, misturada entre os blocos e ondulada por um ruído
# suave no chão, para não ter jeito de bloco. Preta, com a escuridão na transparência.
func _edge_texture() -> ImageTexture:
	var source := mask.get_image()
	var columns := source.get_width()
	var rows := source.get_height()
	var image := Image.create_empty(columns * edge_resolution, rows * edge_resolution, false, Image.FORMAT_RGBA8)
	var corner := Vector2(global_position.x, global_position.z) - Vector2(columns, rows) / 2.0
	for y in image.get_height():
		for x in image.get_width():
			var spot := Vector2(x + 0.5, y + 0.5) / edge_resolution
			var value := _bilinear(source, spot - Vector2(0.5, 0.5))
			var world := corner + spot
			value += (_smooth_noise(world / wobble_size) - 0.5) * wobble
			image.set_pixel(x, y, Color(0, 0, 0, smoothstep(edge_start, edge_end, value)))
	return ImageTexture.create_from_image(image)


static func _bilinear(source: Image, spot: Vector2) -> float:
	var x0 := clampi(floori(spot.x), 0, source.get_width() - 1)
	var y0 := clampi(floori(spot.y), 0, source.get_height() - 1)
	var x1 := mini(x0 + 1, source.get_width() - 1)
	var y1 := mini(y0 + 1, source.get_height() - 1)
	var tx := clampf(spot.x - floorf(spot.x), 0.0, 1.0)
	var ty := clampf(spot.y - floorf(spot.y), 0.0, 1.0)
	var top := lerpf(source.get_pixel(x0, y0).r, source.get_pixel(x1, y0).r, tx)
	var down := lerpf(source.get_pixel(x0, y1).r, source.get_pixel(x1, y1).r, tx)
	return lerpf(top, down, ty)


# Ruído suave de 0 a 1: valores sorteados nos cantos de uma grade de 1, misturados entre eles.
static func _smooth_noise(at: Vector2) -> float:
	var cell := Vector2i(floori(at.x), floori(at.y))
	var t := Vector2(smoothstep(0.0, 1.0, at.x - cell.x), smoothstep(0.0, 1.0, at.y - cell.y))
	var top := lerpf(_corner(cell), _corner(cell + Vector2i(1, 0)), t.x)
	var down := lerpf(_corner(cell + Vector2i(0, 1)), _corner(cell + Vector2i(1, 1)), t.x)
	return lerpf(top, down, t.y)


static func _corner(cell: Vector2i) -> float:
	return float(absi(hash(cell)) % 1000) / 1000.0
