class_name OneWayDoor
extends Interactable
## Porta que só abre por um lado (08-mapa): atalho que Nate abre pelo lado de dentro (interagir) e que depois
## fica aberta para sempre. Pelo outro lado, não abre. O lado de dentro é a frente da porta (−z).

## Quanto a laje desce, em blocos, e em quanto tempo, em segundos.
@export var drop := 0.0
@export var move_time := 0.0

var _open := false

@onready var _slab: Node3D = $Slab
@onready var _collision: CollisionShape3D = $CollisionShape3D


func can_interact() -> bool:
	if _open:
		return false
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return false
	var inside := -global_basis.z
	return (player.global_position - global_position).dot(inside) > 0.0


func interact() -> void:
	_mark_done()
	_open = true
	_collision.set_deferred(&"disabled", true)
	create_tween().tween_property(_slab, ^"position:y", -drop, move_time)


func _restore_done() -> void:
	_open = true
	_collision.disabled = true
	_slab.position.y = -drop
