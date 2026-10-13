@tool
class_name ModelAnimator
extends Node
## O tocador (12-tecnico): toca uma AnimationData no BlockModel pai, passando de uma pose para
## a outra. Toca também no editor, para a prévia.

## Animação tocando. Trocar de animação mistura a pose atual com a nova, no tempo de mistura dela.
@export var animation: AnimationData:
	set = play
## Velocidade da animação (ex.: 0,5 para andar em meia velocidade).
@export var speed_scale := 1.0

var _time := 0.0
var _current_pose := PoseData.new()
var _from_pose: PoseData
var _blend_elapsed := 0.0


## Começa outra animação. Pedir a mesma que já toca não faz nada.
func play(new_animation: AnimationData) -> void:
	if new_animation == animation:
		return
	animation = new_animation
	_time = 0.0
	_from_pose = _current_pose
	_blend_elapsed = 0.0
	if animation == null:
		_apply(PoseData.new())


func _process(delta: float) -> void:
	if animation == null:
		return
	_time += delta * speed_scale
	var pose := animation.sample(_time)
	if _from_pose and _blend_elapsed < animation.blend_time:
		_blend_elapsed += delta
		pose = _from_pose.blended(pose, minf(_blend_elapsed / animation.blend_time, 1.0), true)
	else:
		_from_pose = null
	_apply(pose)


func _apply(pose: PoseData) -> void:
	_current_pose = pose
	var model := get_parent() as BlockModel
	if model:
		model.apply_pose(pose)


func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is not BlockModel:
		return ["O ModelAnimator precisa ser filho de um BlockModel."]
	return []
