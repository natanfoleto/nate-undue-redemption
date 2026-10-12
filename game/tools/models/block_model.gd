@tool
class_name BlockModel
extends Node3D
## O montador (12-tecnico): cria uma parte (nó) para cada caixa do ModelData e aplica a textura.
## Cada parte fica no ponto de giro da caixa, e as filhas giram junto com a mãe.
## Monta também no editor, para a prévia; as partes não são salvas na cena.

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
	if model == null:
		return

	var texture: Texture2D = texture_override if texture_override else model.texture
	if texture == null:
		texture = model.make_flat_texture()
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST # Pixels nítidos.
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
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
		_parts[key] = _make_part(box, key, material, texture_size)

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
		mesh_instance.mesh = box.build_mesh(texture_size)
		mesh_instance.material_override = material
		part = mesh_instance
	part.name = key
	return part
