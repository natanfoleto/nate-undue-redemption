class_name FollowCamera
extends Camera3D
## Câmera do jogo (12-tecnico): ortográfica, com ângulo isométrico, seguindo um alvo.
## O ângulo e o enquadramento vêm do Balance. Treme quando uma magia forte pede (Events.screen_shake), cada vez menos
## até parar.

## Quem a câmera segue.
@export var target: Node3D

# O ponto para onde a câmera puxa (o centro da arena da Boiúna) e quanto ela puxa, de 0 (só Nate) a 1 (só o ponto).
var _focus := Vector3.ZERO
var _focus_weight := 0.0
var _focus_tween: Tween
var _shake := 0.0
var _shake_time := 0.0
var _shake_left := 0.0


func _ready() -> void:
	var stats := Balance.camera
	projection = PROJECTION_ORTHOGONAL
	size = stats.view_height
	rotation_degrees = Vector3(-stats.pitch, stats.yaw, 0.0)
	_follow()
	Events.screen_shake.connect(_on_screen_shake)


# Segue no mesmo passo em que Nate anda, para um não tremer contra o outro.
func _physics_process(_delta: float) -> void:
	_follow()


## Puxa a câmera para [param point], na medida de [param weight] (0 só Nate, 1 só o ponto), aos poucos, em
## [param seconds] segundos: na luta da Boiúna, ela mostra mais da arena; nas cenas, olha para a Boiúna.
func set_focus(point: Vector3, weight: float, seconds: float) -> void:
	_focus = point
	_tween_focus(weight, seconds)


## Volta a seguir só Nate, aos poucos.
func clear_focus(seconds: float) -> void:
	_tween_focus(0.0, seconds)


func _tween_focus(weight: float, seconds: float) -> void:
	if _focus_tween:
		_focus_tween.kill()
	if seconds <= 0.0:
		_focus_weight = weight
		return
	_focus_tween = create_tween()
	_focus_tween.tween_property(self, ^"_focus_weight", weight, seconds).set_trans(Tween.TRANS_SINE)


# Um tremor mais fraco que o que ainda falta do atual não muda nada.
func _on_screen_shake(strength: float, seconds: float) -> void:
	if seconds <= 0.0 or strength < _current_shake():
		return
	_shake = strength
	_shake_time = seconds
	_shake_left = seconds


func _process(delta: float) -> void:
	if _shake_left <= 0.0:
		return
	_shake_left = maxf(_shake_left - delta, 0.0)
	var strength := _current_shake()
	h_offset = randf_range(-strength, strength)
	v_offset = randf_range(-strength, strength)


func _current_shake() -> float:
	return _shake * _shake_left / _shake_time if _shake_time > 0.0 else 0.0


func _follow() -> void:
	if target:
		var center := target.global_position.lerp(_focus, _focus_weight)
		global_position = center + global_basis.z * Balance.camera.distance
