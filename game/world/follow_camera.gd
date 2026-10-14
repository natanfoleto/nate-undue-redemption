class_name FollowCamera
extends Camera3D
## Câmera do jogo (12-tecnico): ortográfica, com ângulo isométrico, seguindo um alvo.
## O ângulo e o enquadramento vêm do Balance. Treme quando uma magia forte pede (Events.screen_shake), cada vez menos
## até parar.

## Quem a câmera segue.
@export var target: Node3D

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
		global_position = target.global_position + global_basis.z * Balance.camera.distance
