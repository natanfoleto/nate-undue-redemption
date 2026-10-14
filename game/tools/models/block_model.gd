@tool
class_name BlockModel
extends Node3D
## O montador (12-tecnico): cria uma parte (nó) para cada caixa do ModelData e aplica a textura.
## Cada parte fica no ponto de giro da caixa, e as filhas giram junto com a mãe.
## Monta também no editor, para a prévia; as partes não são salvas na cena.

## Camada de desenho dos modelos de blocos (personagens, objetos e itens): a escuridão das áreas escuras (DarkArea)
## só escurece o terreno, na camada 1.
const MODEL_LAYER := 2

## Modelo a montar.
@export var model: ModelData:
	set(value):
		if model and model.changed.is_connected(rebuild):
			model.changed.disconnect(rebuild)
		model = value
		if model:
			model.changed.connect(rebuild)
		rebuild()
## Variante: o mesmo modelo com outra textura (06-mobs).
@export var texture_override: Texture2D:
	set(value):
		texture_override = value
		rebuild()

var _parts: Dictionary[StringName, Node3D] = {}
var _rest_positions: Dictionary[StringName, Vector3] = {}
var _material: StandardMaterial3D
var _height := 0.0


func _ready() -> void:
	rebuild()


## Desmonta e monta de novo. Acontece sozinho quando os dados mudam.
func rebuild() -> void:
	if not is_node_ready():
		return
	# Liberar uma parte libera as filhas junto: as que já se foram ficam de fora.
	for part in _parts.values():
		if is_instance_valid(part):
			part.free()
	_parts.clear()
	_rest_positions.clear()
	_material = null
	_height = 0.0
	if model == null:
		return

	var texture: Texture2D = texture_override if texture_override else model.texture
	if texture == null:
		texture = model.make_flat_texture()
	_material = StandardMaterial3D.new()
	_material.albedo_texture = texture
	_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST # Pixels nítidos.
	_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_material.emission = Color.WHITE
	var texture_size := Vector2(texture.get_size())

	var boxes: Dictionary[StringName, BoxData] = {}
	for i in model.boxes.size():
		var box := model.boxes[i]
		if box == null:
			continue
		# Caixa sem nome monta, mas não pode ser citada.
		var key := box.name if box.name != &"" else StringName("box_%d" % i)
		if boxes.has(key):
			push_warning("Modelo %s: a caixa \"%s\" se repete e foi ignorada." % [model.resource_path, key])
			continue
		boxes[key] = box
		_parts[key] = _make_part(box, key, _material, texture_size)
		_height = maxf(_height, (box.position.y + box.size.y) / BoxData.PIXELS_PER_BLOCK)

	for key in _parts:
		var box := boxes[key]
		var part := _parts[key]
		var parent_node: Node3D = self
		var parent_pivot := Vector3.ZERO
		if box.parent != &"":
			if box.parent != key and _parts.has(box.parent) and not part.is_ancestor_of(_parts[box.parent]):
				parent_node = _parts[box.parent]
				parent_pivot = boxes[box.parent].pivot
			else:
				push_warning("Modelo %s: a caixa \"%s\" tem um pai que não existe ou que cria um ciclo." % [model.resource_path, key])
		if parent_node == self:
			# Interna: Duplicar o BlockModel não copia as partes, que ele mesmo monta de novo.
			add_child(part, false, Node.INTERNAL_MODE_BACK)
		else:
			parent_node.add_child(part)
		part.position = (box.pivot - parent_pivot) / BoxData.PIXELS_PER_BLOCK
		_rest_positions[key] = part.position


## Altura do modelo em repouso, em blocos, sem contar a escala.
func height() -> float:
	return _height


## A parte de uma caixa, para prender coisas nela (a arma na mão de Nate). Nula se não existe.
func get_part(part_name: StringName) -> Node3D:
	return _parts.get(part_name)


## Brilho branco do aviso de golpe comum (10-arte-audio), de 0 (nenhum) a 1. Outra cor serve para o que
## brilha sozinho (a Bola de Fogo, a praga).
func set_glow(strength: float, color := Color.WHITE) -> void:
	if _material == null:
		return
	_material.emission = color
	_material.emission_enabled = strength > 0.0
	_material.emission_energy_multiplier = strength


## Brilho próprio de uma parte, na cor dada (o muiraquitã aceso), de 0 (nenhum) a 1 ou mais.
func set_part_glow(part_name: StringName, color: Color, strength: float) -> void:
	var part := _parts.get(part_name) as MeshInstance3D
	if part == null or _material == null:
		return
	if strength <= 0.0:
		part.material_override = _material
		return
	var material := _material.duplicate() as StandardMaterial3D
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = strength
	part.material_override = material


## Põe as partes na pose: o giro e o deslocamento contam a partir do repouso.
func apply_pose(pose: PoseData) -> void:
	for key in _parts:
		var angles: Vector3 = pose.rotations.get(key, Vector3.ZERO)
		var offset: Vector3 = pose.offsets.get(key, Vector3.ZERO)
		_parts[key].rotation_degrees = angles
		_parts[key].position = _rest_positions[key] + offset / BoxData.PIXELS_PER_BLOCK


func _make_part(box: BoxData, key: StringName, material: Material, texture_size: Vector2) -> Node3D:
	var part: Node3D
	if box.size == Vector3i.ZERO:
		part = Node3D.new()
	else:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = box.build_mesh(texture_size, model.bevel)
		mesh_instance.material_override = material
		mesh_instance.layers = MODEL_LAYER
		part = mesh_instance
	part.name = key
	return part
