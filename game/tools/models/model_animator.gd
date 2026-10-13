@tool
class_name ModelAnimator
extends Node
## O tocador (12-tecnico): toca uma AnimationData no BlockModel pai, passando de uma pose para
## a outra. Toca também no editor, para a prévia.
## Uma segunda animação pode tocar por cima, só nas partes que ela cita (os braços puxando o tiro enquanto
## as pernas andam).

## Animação tocando. Trocar de animação mistura a pose atual com a nova, no tempo de mistura dela.
@export var animation: AnimationData:
	set(value):
		animation = value
		_time = 0.0
		_from_pose = _current_pose
		_blend_elapsed = 0.0
		if animation == null:
			_apply(PoseData.new())
## Velocidade da animação (ex.: 0,5 para andar em meia velocidade).
@export var speed_scale := 1.0

var _time := 0.0
var _current_pose := PoseData.new()
var _from_pose: PoseData
var _blend_elapsed := 0.0

var _overlay: AnimationData
var _overlay_time := 0.0
var _overlay_speed := 1.0
var _overlay_weight := 0.0
var _overlay_target := 0.0


## Começa outra animação. Pedir a mesma que já toca não faz nada.
func play(new_animation: AnimationData) -> void:
	if new_animation != animation:
		animation = new_animation


## Começa a animação do início, mesmo que seja a que já toca (um golpe repetido).
func restart(new_animation: AnimationData) -> void:
	animation = new_animation


## Toca uma animação por cima da principal. A mistura de entrada e de saída usa o tempo de mistura dela.
func play_overlay(new_overlay: AnimationData, speed := 1.0) -> void:
	if new_overlay != _overlay:
		_overlay_time = 0.0
		if _overlay == null:
			_overlay_weight = 0.0
	_overlay = new_overlay
	_overlay_speed = speed
	_overlay_target = 1.0


## Tira a animação de cima, misturando de volta para a principal.
func stop_overlay() -> void:
	_overlay_target = 0.0


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
	if _overlay:
		var step := delta / _overlay.blend_time if _overlay.blend_time > 0.0 else 1.0
		_overlay_weight = move_toward(_overlay_weight, _overlay_target, step)
		_overlay_time += delta * _overlay_speed
		if _overlay_weight > 0.0:
			pose = pose.overlaid(_overlay.sample(_overlay_time), _overlay_weight)
		elif _overlay_target == 0.0:
			_overlay = null
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
