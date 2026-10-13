class_name DarkArea
extends Node3D
## Área escura (08-mapa): sem a Luz Ancestral, Nate para na borda; com ela, o muiraquitã ilumina um círculo em
## volta dele (05-itens). A escuridão é uma tampa preta sobre a área, aberta só nesse círculo.

const SHADER := preload("res://world/darkness.gdshader")

## Retângulo da área no chão, centrado no nó, em blocos.
@export var area_size := Vector2.ZERO
## Altura da tampa de escuridão, em blocos: a do alto das paredes.
@export var cover_height := 0.0
## Largura da borda suave do círculo de luz, em blocos.
@export var light_edge := 0.0
## Os blocos escuros (um ponto por bloco, branco no escuro), com a margem em volta: a tampa segue essa forma, com a
## borda suave; e a margem, em blocos, para a borda sumir aos poucos fora da área.
@export var mask: Texture2D
@export var margin := 0.0

var _material := ShaderMaterial.new()
var _barrier: CollisionShape3D


func _ready() -> void:
	add_to_group(&"dark_areas")
	_material.shader = SHADER
	_material.set_shader_parameter(&"edge", light_edge)
	_material.set_shader_parameter(&"floor_height", global_position.y)
	_material.set_shader_parameter(&"mask", mask)
	var mesh := PlaneMesh.new()
	mesh.size = area_size + Vector2.ONE * margin * 2.0
	var cover := MeshInstance3D.new()
	cover.mesh = mesh
	cover.material_override = _material
	cover.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cover.position.y = cover_height
	add_child(cover)
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
	var lit := GameState.has_light()
	if lit and not _barrier.disabled:
		_barrier.disabled = true
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player:
		_material.set_shader_parameter(&"center", player.global_position)
	_material.set_shader_parameter(&"radius", Balance.player.light_radius if lit and player else 0.0)
