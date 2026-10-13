extends SceneTree
# Gera as bibliotecas de blocos das áreas e da sala de teste (world/blocks/), com as texturas pintadas à mão
# (pacote CC0 do drummyfish, 32 px por bloco) e as feitas para o jogo (fungos e padrões marajoara). Os geradores
# das áreas acham cada bloco pelo nome. Rodar a partir da raiz do repositório:
#   godot --headless --path game -s res://tools/areas/make_blocks.gd
#
# Cada bloco é um dicionário: name, e um dos tipos abaixo, com tint (cor que multiplica a textura) e glow (brilho):
# - texture: cubo com a textura (cutout: recorte, nas folhas; side: as laterais e o fundo com outra textura);
# - liquid: cubo de água ou lava, com a faixa de quadros animada (shader liquid.gdshader), fps quadros por segundo;
# - fence: cerca na borda norte do bloco (−z), sem colisão: a barreira invisível segura quem anda;
# - plant: planta em X (duas folhas cruzadas), sem colisão, com height blocos de altura;
# - mushroom: cogumelo pequeno, pé e chapéu, sem colisão.
# Os blocos de chão com ramps ganham as peças de rampa do próprio chão (rampas de 1 a 3 blocos e os 2 cantos,
# terrain_builder.gd).
# No fim de cada lista entram o bloco invisível e a escada.

const PAINTED := "res://assets/textures/painted/"
const OURS := "res://assets/textures/"
const LIQUID_SHADER := "res://world/blocks/liquid.gdshader"
const BUILDER := "res://tools/areas/terrain_builder.gd"


const MINE := [
	{"name": "Rocha da mina", "texture": PAINTED + "stone", "tint": Color(0.82, 0.78, 0.72)},
	{"name": "Chão de terra", "texture": PAINTED + "dirt", "tint": Color(0.95, 0.85, 0.75), "ramps": true},
	{"name": "Grama", "texture": PAINTED + "grass", "side": PAINTED + "grass_side", "tint": Color(0.8, 0.9, 0.7), "ramps": true},
	{"name": "Tronco", "texture": PAINTED + "bark"},
	{"name": "Folhas", "texture": PAINTED + "leaves", "tint": Color(0.85, 0.95, 0.8), "cutout": true},
	{"name": "Tábuas", "texture": PAINTED + "planks", "tint": Color(0.8, 0.72, 0.65), "ramps": true},
	{"name": "Rocha", "texture": PAINTED + "cobble", "tint": Color(0.85, 0.85, 0.85)},
	{"name": "Pedra do povo antigo", "texture": PAINTED + "sandstone_brick"},
	{"name": "Parede rachada", "texture": PAINTED + "mossy_cobble"},
	{"name": "Fundo da vala", "texture": PAINTED + "dirt", "tint": Color(0.35, 0.3, 0.26)},
	{"name": "Grama clara", "texture": PAINTED + "grass", "side": PAINTED + "grass_side", "tint": Color(0.9, 0.97, 0.72), "ramps": true},
	{"name": "Grama escura", "texture": PAINTED + "grass", "side": PAINTED + "grass_side", "tint": Color(0.68, 0.8, 0.62), "ramps": true},
	{"name": "Cascalho", "texture": PAINTED + "gravel", "tint": Color(0.8, 0.74, 0.68), "ramps": true},
	{"name": "Terra escura", "texture": PAINTED + "dirt", "tint": Color(0.68, 0.58, 0.5), "ramps": true},
	{"name": "Folhas da mata", "texture": PAINTED + "jungle_leaves", "tint": Color(0.9, 1.0, 0.85), "cutout": true},
	{"name": "Areia", "texture": PAINTED + "sand", "tint": Color(0.95, 0.9, 0.82)},
	{"name": "Madeira velha", "texture": PAINTED + "wood", "tint": Color(0.62, 0.55, 0.48)},
	{"name": "Telhado", "texture": PAINTED + "clay_brick", "tint": Color(0.72, 0.5, 0.42)},
	{"name": "Madeira azul", "texture": PAINTED + "wood", "tint": Color(0.55, 0.75, 0.95)},
	{"name": "Madeira amarela", "texture": PAINTED + "wood", "tint": Color(1.0, 0.88, 0.5)},
	{"name": "Madeira verde", "texture": PAINTED + "wood", "tint": Color(0.6, 0.88, 0.62)},
	{"name": "Madeira branca", "texture": PAINTED + "wood", "tint": Color(1.0, 0.98, 0.92)},
	{"name": "Água escura", "liquid": PAINTED + "water_strip", "tint": Color(0.35, 0.5, 0.6), "glow": 0.15, "fps": 1.5},
	{"name": "Rio", "liquid": PAINTED + "river_strip", "tint": Color(0.75, 0.82, 0.78), "glow": 0.05, "fps": 1.5},
	{"name": "Cerca", "fence": PAINTED + "planks", "tint": Color(0.7, 0.62, 0.55)},
	{"name": "Trilho", "texture": PAINTED + "rail", "flat": true},
	{"name": "Capim", "plant": PAINTED + "grass_tuft", "tint": Color(0.85, 0.95, 0.75)},
	{"name": "Capim alto", "plant": PAINTED + "grass_tall", "tint": Color(0.85, 0.95, 0.75)},
	{"name": "Capim da mata", "plant": PAINTED + "jungle_grass", "height": 2.0},
	{"name": "Papiro", "plant": PAINTED + "papyrus"},
	{"name": "Flor azul", "plant": PAINTED + "flower_blue"},
	{"name": "Flor amarela", "plant": PAINTED + "flower_yellow"},
	{"name": "Flor vermelha", "plant": PAINTED + "flower_red"},
	{"name": "Rocha funda", "texture": PAINTED + "stone", "tint": Color(0.5, 0.48, 0.46)},
]
const FOREST := [
	{"name": "Rocha", "texture": PAINTED + "stone", "tint": Color(0.6, 0.68, 0.85)},
	{"name": "Chão de terra", "texture": PAINTED + "clay", "tint": Color(0.62, 0.75, 0.78), "ramps": true},
	{"name": "Chão de musgo", "texture": PAINTED + "grass", "side": PAINTED + "grass_side", "tint": Color(0.45, 0.62, 0.55), "ramps": true},
	{"name": "Pedra do povo antigo", "texture": PAINTED + "sandstone_brick", "tint": Color(0.85, 0.85, 0.9)},
	{"name": "Parede rachada", "texture": PAINTED + "mossy_cobble", "tint": Color(0.85, 0.9, 0.95)},
	{"name": "Pé de cogumelo", "texture": OURS + "mushroom_stem"},
	{"name": "Chapéu ciano", "texture": OURS + "mushroom_cap_cyan", "glow": 0.9},
	{"name": "Chapéu verde-limão", "texture": OURS + "mushroom_cap_lime", "glow": 0.9},
	{"name": "Lugar do mural", "texture": PAINTED + "desert_stone", "tint": Color(0.95, 0.9, 0.85)},
	{"name": "Água brilhante", "liquid": PAINTED + "water_strip", "tint": Color(0.35, 0.85, 0.8), "glow": 0.7, "fps": 1.5},
	{"name": "Cerca", "fence": OURS + "mushroom_stem"},
	{"name": "Cogumelo ciano", "mushroom": OURS + "mushroom_cap_cyan", "glow": 1.4},
	{"name": "Cogumelo verde-limão", "mushroom": OURS + "mushroom_cap_lime", "glow": 1.4},
	{"name": "Rocha funda", "texture": PAINTED + "stone", "tint": Color(0.42, 0.5, 0.66)},
]
const RUINS := [
	{"name": "Parede marajoara", "texture": OURS + "marajoara_wall", "tint": Color(0.95, 0.9, 0.88)},
	{"name": "Piso marajoara", "texture": OURS + "marajoara_floor", "tint": Color(0.9, 0.88, 0.84), "ramps": true},
	{"name": "Chão das minas antigas", "texture": PAINTED + "gravel", "tint": Color(0.75, 0.7, 0.66), "ramps": true},
	{"name": "Padrão de jade", "texture": OURS + "marajoara_jade", "glow": 1.2},
	{"name": "Parede rachada", "texture": PAINTED + "mossy_cobble", "tint": Color(0.9, 0.85, 0.8)},
	{"name": "Fundo do vão", "texture": PAINTED + "dirt", "tint": Color(0.25, 0.2, 0.18)},
	{"name": "Pedra dos murais", "texture": PAINTED + "sandstone_brick", "tint": Color(0.95, 0.85, 0.7)},
	{"name": "Rocha", "texture": PAINTED + "stone", "tint": Color(0.62, 0.56, 0.5)},
	{"name": "Rocha queimada", "texture": PAINTED + "stone", "tint": Color(0.42, 0.32, 0.28)},
	{"name": "Lava", "liquid": PAINTED + "lava_strip", "glow": 1.6, "fps": 2.0},
	{"name": "Balaustrada", "fence": PAINTED + "sandstone_brick", "tint": Color(0.95, 0.85, 0.7)},
]
const TEST := [
	{"name": "Pedra", "texture": PAINTED + "cobble"},
]
const STAIRS_LOOK := {
	"mine": [PAINTED + "stone_brick", Color(0.85, 0.8, 0.75)],
	"forest": [PAINTED + "stone_brick", Color(0.65, 0.72, 0.85)],
	"ruins": [OURS + "marajoara_floor", Color(0.9, 0.88, 0.84)],
	"test": [PAINTED + "stone_brick", Color.WHITE],
}


func _initialize() -> void:
	_save(MINE, "mine", "res://world/blocks/mine_blocks.tres")
	_save(FOREST, "forest", "res://world/blocks/forest_blocks.tres")
	_save(RUINS, "ruins", "res://world/blocks/ruins_blocks.tres")
	_save(TEST, "test", "res://world/blocks/test_blocks.tres")
	quit()


func _save(blocks: Array, look: String, path: String) -> void:
	var builder: Script = load(BUILDER)
	var library := MeshLibrary.new()
	var shape := BoxShape3D.new()
	for i in blocks.size():
		var block: Dictionary = blocks[i]
		var tint: Color = block.get("tint", Color.WHITE)
		var glow: float = block.get("glow", 0.0)
		var mesh: Mesh
		var solid := true
		if block.has("liquid"):
			mesh = BoxMesh.new()
			(mesh as BoxMesh).material = _liquid_material(block.liquid, tint, glow, block.get("fps", 4.0))
		elif block.has("fence"):
			mesh = _fence_mesh(builder, _material(block.fence, tint, glow, false))
			solid = false
		elif block.has("plant"):
			mesh = _plant_mesh(_plant_material(block.plant, tint), block.get("height", 1.0))
			solid = false
		elif block.has("mushroom"):
			mesh = _mushroom_mesh(builder, _material(OURS + "mushroom_stem", Color.WHITE, 0.0, false), _material(block.mushroom, tint, glow, false))
			solid = false
		elif block.get("flat", false):
			mesh = _flat_mesh(_plant_material(block.texture, tint))
			solid = false
		else:
			var material := _material(block.texture, tint, glow, block.get("cutout", false))
			if block.has("side"):
				mesh = _topped_mesh(material, _material(block.side, tint, glow, false))
			else:
				mesh = BoxMesh.new()
				(mesh as BoxMesh).material = material
		library.create_item(i)
		library.set_item_name(i, block.name)
		library.set_item_mesh(i, mesh)
		if solid:
			library.set_item_shapes(i, [shape, Transform3D.IDENTITY])
	var next := blocks.size()
	for block: Dictionary in blocks:
		if not block.get("ramps", false):
			continue
		var tint: Color = block.get("tint", Color.WHITE)
		var slope := _slope_material(block.texture, tint)
		var side := _material(block.get("side", block.texture), tint, 0.0, false)
		for length in range(1, builder.MAX_RAMP + 1):
			for step in length:
				library.create_item(next)
				library.set_item_name(next, builder.ramp_name(block.name, step, length))
				library.set_item_mesh(next, builder.ramp_mesh(step, length, slope, side))
				library.set_item_shapes(next, [builder.ramp_shape(step, length), Transform3D.IDENTITY])
				next += 1
		for corner in ["inner", "outer"]:
			library.create_item(next)
			library.set_item_name(next, builder.ramp_name(block.name, 0, 1, corner))
			library.set_item_mesh(next, builder.corner_mesh(corner == "inner", slope, side))
			library.set_item_shapes(next, [builder.corner_shape(corner == "inner"), Transform3D.IDENTITY])
			next += 1
	var barrier := next
	library.create_item(barrier)
	library.set_item_name(barrier, "Invisível")
	library.set_item_shapes(barrier, [shape, Transform3D.IDENTITY])
	var stairs := barrier + 1
	var stairs_look: Array = STAIRS_LOOK[look]
	library.create_item(stairs)
	library.set_item_name(stairs, "Escada")
	library.set_item_mesh(stairs, builder.stairs_mesh(_material(stairs_look[0], stairs_look[1], 0.0, false)))
	library.set_item_shapes(stairs, [builder.stairs_shape(), Transform3D.IDENTITY])
	print(path, ": ", error_string(ResourceSaver.save(library, path)), " (", stairs + 1, " blocos)")


func _material(texture_path: String, tint: Color, glow: float, cutout: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(texture_path + ".png")
	material.albedo_color = tint
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	if glow > 0.0:
		material.emission_enabled = true
		material.emission_texture = material.albedo_texture
		material.emission_energy_multiplier = glow
	if cutout:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	return material


# A face de cima das rampas: a textura segue a inclinação (sem projeção do mundo), um quadro por bloco.
func _slope_material(texture_path: String, tint: Color) -> StandardMaterial3D:
	var material := _material(texture_path, tint, 0.0, false)
	material.uv1_triplanar = false
	material.uv1_world_triplanar = false
	return material


func _plant_material(texture_path: String, tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(texture_path + ".png")
	material.albedo_color = tint
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return material


func _liquid_material(texture_path: String, tint: Color, glow: float, frames_per_second: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load(LIQUID_SHADER)
	material.set_shader_parameter(&"frames_texture", load(texture_path + ".png"))
	material.set_shader_parameter(&"frames_per_second", frames_per_second)
	material.set_shader_parameter(&"tint", tint)
	material.set_shader_parameter(&"glow", glow)
	return material


# Bloco com a face de cima diferente das laterais e da de baixo: uma superfície para cada material.
func _topped_mesh(top: Material, side: Material) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var corners := [
		Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5), Vector3(0.5, 0.5, -0.5), Vector3(-0.5, 0.5, -0.5),
		Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5), Vector3(0.5, 0.5, 0.5), Vector3(-0.5, 0.5, 0.5),
	]
	var faces := [[3, 2, 6, 7], [0, 1, 5, 4], [4, 5, 6, 7], [0, 1, 2, 3], [1, 2, 6, 5], [0, 3, 7, 4]]
	for part in 2:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in faces.size():
			if (i == 0) != (part == 0):
				continue
			var quad: Array = faces[i]
			var a: Vector3 = corners[quad[0]]
			var b: Vector3 = corners[quad[1]]
			var c: Vector3 = corners[quad[2]]
			var d: Vector3 = corners[quad[3]]
			# A frente para fora: no Godot, o sentido horário visto de fora (o produto vetorial aponta para dentro).
			var points := [a, b, c, a, c, d]
			if (b - a).cross(c - a).dot((a + c) / 2.0) > 0.0:
				points = [a, c, b, a, d, c]
			for point: Vector3 in points:
				surface.set_uv(Vector2(point.x + point.z, -point.y))
				surface.add_vertex(point)
		surface.generate_normals()
		surface.set_material(top if part == 0 else side)
		surface.commit(mesh)
	return mesh


# Cerca na borda norte do bloco: dois postes e duas travessas, da altura do chão para cima.
func _fence_mesh(builder: Script, material: Material) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for post_x: float in [-0.44, 0.32]:
		builder.box(surface, Vector3(post_x, -0.5, -0.5), Vector3(post_x + 0.12, 0.38, -0.38))
	for rail_y: float in [-0.12, 0.2]:
		builder.box(surface, Vector3(-0.5, rail_y, -0.48), Vector3(0.5, rail_y + 0.08, -0.4))
	surface.generate_normals()
	surface.set_material(material)
	var mesh := ArrayMesh.new()
	surface.commit(mesh)
	return mesh


# Planta em X: duas folhas cruzadas na diagonal do bloco, com a textura inteira em cada uma.
func _plant_mesh(material: Material, plant_height: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top := -0.5 + plant_height
	for diagonal: Array in [[Vector2(-0.45, -0.45), Vector2(0.45, 0.45)], [Vector2(-0.45, 0.45), Vector2(0.45, -0.45)]]:
		var a: Vector2 = diagonal[0]
		var b: Vector2 = diagonal[1]
		var corners := [Vector3(a.x, -0.5, a.y), Vector3(b.x, -0.5, b.y), Vector3(b.x, top, b.y), Vector3(a.x, top, a.y)]
		var uvs := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for index: int in [0, 1, 2, 0, 2, 3]:
			surface.set_uv(uvs[index])
			surface.add_vertex(corners[index])
	surface.generate_normals()
	surface.set_material(material)
	var mesh := ArrayMesh.new()
	surface.commit(mesh)
	return mesh


# Decalque no chão (o trilho): um quadrado deitado logo acima do bloco de baixo.
func _flat_mesh(material: Material) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y := -0.48
	var corners := [Vector3(-0.5, y, -0.5), Vector3(0.5, y, -0.5), Vector3(0.5, y, 0.5), Vector3(-0.5, y, 0.5)]
	var uvs := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	for index: int in [0, 1, 2, 0, 2, 3]:
		surface.set_uv(uvs[index])
		surface.add_vertex(corners[index])
	surface.generate_normals()
	surface.set_material(material)
	var mesh := ArrayMesh.new()
	surface.commit(mesh)
	return mesh


# Cogumelo pequeno: pé fino e chapéu largo, que brilha.
func _mushroom_mesh(builder: Script, stem: Material, cap: Material) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for part in 2:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		if part == 0:
			builder.box(surface, Vector3(-0.08, -0.5, -0.08), Vector3(0.08, -0.15, 0.08))
		else:
			builder.box(surface, Vector3(-0.28, -0.15, -0.28), Vector3(0.28, 0.0, 0.28))
		surface.generate_normals()
		surface.set_material(stem if part == 0 else cap)
		surface.commit(mesh)
	return mesh
