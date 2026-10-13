class_name CrackedWall
extends StaticBody3D
## Parede rachada (08-mapa): quebra com qualquer golpe ou tiro de Nate quando ele já aprendeu a Terra (05-itens);
## sem a Terra, só treme, como pedra firme. Quebrada, fica assim para sempre.

## Identificador único no mapa.
@export var save_id: StringName
## Tamanho da parede, em blocos: largura (x), altura e profundidade (z).
@export var size := Vector3.ONE
## O mesmo material dos blocos de parede rachada da área.
@export var material: Material
## Tremor da pedra firme: distância, em blocos, e duração, em segundos.
@export var shake := 0.0
@export var shake_time := 0.0
## Poeira da parede quebrando.
@export var dust_color := Color.WHITE
@export var dust_look: EffectLook

var _broken := false
var _mesh: MeshInstance3D


func _ready() -> void:
	if SaveSystem.has_record(SaveSystem.OPENED, save_id):
		queue_free()
		return
	add_to_group(&"breakables")
	var box := BoxMesh.new()
	box.size = size
	box.material = material
	_mesh = MeshInstance3D.new()
	_mesh.mesh = box
	_mesh.position.y = size.y / 2.0
	add_child(_mesh)
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = size.y / 2.0
	add_child(collision)


## Os pontos em que um golpe acerta a parede: o centro de cada bloco dela, no chão.
func hit_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for x in roundi(size.x):
		for z in roundi(size.z):
			points.append(global_transform * Vector3(x - size.x / 2.0 + 0.5, 0.0, z - size.z / 2.0 + 0.5))
	return points


## Um golpe de Nate acertou a parede.
func take_strike() -> void:
	_hit()


## Um tiro de Nate acertou a parede.
func take_shot() -> void:
	_hit()


func _hit() -> void:
	if _broken:
		return
	if not GameState.has_learned(&"earth"):
		# Sem a Terra, a parede responde com o som de pedra firme (08-mapa).
		AudioManager.play(&"wall_firm", global_position)
		var tween := create_tween()
		tween.tween_property(_mesh, ^"position:x", shake, shake_time / 4.0)
		tween.tween_property(_mesh, ^"position:x", -shake, shake_time / 2.0)
		tween.tween_property(_mesh, ^"position:x", 0.0, shake_time / 4.0)
		return
	_broken = true
	SaveSystem.record(SaveSystem.OPENED, save_id)
	AudioManager.play(&"wall_break", global_position)
	SpellEffects.burst(get_parent(), global_position, dust_color, maxf(size.x, size.z), dust_look)
	queue_free()
