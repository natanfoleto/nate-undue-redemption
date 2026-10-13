class_name FollowCamera
extends Camera3D
## Câmera do jogo (12-tecnico): ortográfica, com ângulo isométrico, seguindo um alvo.
## O ângulo e o enquadramento vêm do Balance.

## Quem a câmera segue.
@export var target: Node3D


func _ready() -> void:
	var stats := Balance.camera
	projection = PROJECTION_ORTHOGONAL
	size = stats.view_height
	rotation_degrees = Vector3(-stats.pitch, stats.yaw, 0.0)
	_follow()


# Segue no mesmo passo em que Nate anda, para um não tremer contra o outro.
func _physics_process(_delta: float) -> void:
	_follow()


func _follow() -> void:
	if target:
		global_position = target.global_position + global_basis.z * Balance.camera.distance
