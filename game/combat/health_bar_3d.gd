class_name HealthBar3D
extends Node3D
## Barra de vida sobre a cabeça do mob (09-interface): aparece só depois de ele levar dano.
## As duas faixas sempre olham para a câmera.

## Tamanho da barra, em blocos.
@export var size := Vector2.ZERO
## Altura da barra acima da cabeça, em blocos.
@export var lift := 0.0
@export var back_color := Color.BLACK
@export var fill_color := Color.WHITE

var _fill_mesh: QuadMesh


func _ready() -> void:
	visible = false
	_add_quad(size, back_color, 0.0)
	_fill_mesh = _add_quad(size, fill_color, size.y / 10.0)


func show_value(value: int, max_value: int) -> void:
	visible = true
	var fraction := clampf(float(value) / max_value, 0.0, 1.0) if max_value > 0 else 0.0
	# A faixa encolhe a partir da esquerda.
	_fill_mesh.size = Vector2(size.x * fraction, size.y)
	_fill_mesh.center_offset = Vector3(-size.x * (1.0 - fraction) / 2.0, 0.0, _fill_mesh.center_offset.z)


# Faixa virada para a câmera; [param depth] a põe à frente da outra.
func _add_quad(quad_size: Vector2, color: Color, depth: float) -> QuadMesh:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.billboard_keep_scale = true
	material.albedo_color = color
	var mesh := QuadMesh.new()
	mesh.size = quad_size
	mesh.center_offset = Vector3(0.0, 0.0, depth)
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return mesh
