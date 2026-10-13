class_name WarningMarker
extends MeshInstance3D
## Marca de aviso no chão (03-regras): a mesma forma da área do golpe, desenhada pelos mesmos dados.
## Fica parada no mundo onde o golpe começou, mesmo se quem golpeia se mexe.

const SHADER := preload("res://combat/warning_marker.gdshader")
## Altura sobre o chão, em blocos: o bastante para não piscar com ele.
const FLOOR_OFFSET := 0.02


func _ready() -> void:
	top_level = true
	visible = false
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader_material := ShaderMaterial.new()
	shader_material.shader = SHADER
	material_override = shader_material


## Mostra a área do golpe saindo de [param origin] na direção [param forward].
func show_attack(attack: AttackData, origin: Vector3, forward: Vector3) -> void:
	mesh = AreaMesh.build(attack)
	global_position = Vector3(origin.x, origin.y + FLOOR_OFFSET, origin.z)
	global_rotation = Vector3(0.0, atan2(-forward.x, -forward.z), 0.0)
	set_progress(0.0)
	visible = true


## Quanto da preparação já passou, de 0 a 1.
func set_progress(progress: float) -> void:
	(material_override as ShaderMaterial).set_shader_parameter(&"progress", progress)


func hide_attack() -> void:
	visible = false
