class_name Lever
extends Interactable
## Alavanca (08-mapa): interagir de perto ou acertar com um tiro de longe abre um portão ou baixa uma ponte.

signal pulled

## Giro do cabo puxado, em graus, e o tempo para puxar, em segundos.
@export var pulled_angle := 0.0
@export var pull_time := 0.0

var _pulled := false

@onready var _handle: Node3D = $Handle


func can_interact() -> bool:
	return not _pulled


func interact() -> void:
	_pull()


## Um projétil acertou a alavanca.
func take_shot() -> void:
	if not _pulled:
		_pull()


func is_pulled() -> bool:
	return _pulled


func _pull() -> void:
	_pulled = true
	_mark_done()
	create_tween().tween_property(_handle, ^"rotation_degrees:x", pulled_angle, pull_time)
	pulled.emit()


func _restore_done() -> void:
	_pulled = true
	_handle.rotation_degrees.x = pulled_angle
