class_name Gate
extends StaticBody3D
## Portão (08-mapa): grades que descem para dentro do chão quando abrem. Fechado, bloqueia a passagem,
## os tiros e a visão dos mobs. Abre pela alavanca ligada a ele ou pela arena.

## Alavanca que abre o portão (vazio nas arenas, que abrem e fecham por conta própria).
@export var lever: Lever
## Quanto as grades descem, em blocos, e em quanto tempo, em segundos.
@export var drop := 0.0
@export var move_time := 0.0
## Começa aberto (as arenas fecham os portões só quando a luta começa).
@export var starts_open := false

var _open := false

@onready var _bars: Node3D = $Bars
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	if lever:
		lever.pulled.connect(open)
	# Pelo jogo salvo, e não pela alavanca, que pode ficar pronta depois do portão.
	var lever_pulled := lever != null and SaveSystem.has_record(SaveSystem.OPENED, lever.save_id)
	if starts_open or lever_pulled:
		_set_open(true, false)


func open() -> void:
	_set_open(true, true)


func close() -> void:
	_set_open(false, true)


func is_open() -> bool:
	return _open


func _set_open(value: bool, animated: bool) -> void:
	_open = value
	_collision.set_deferred(&"disabled", value)
	var target := -drop if value else 0.0
	if animated:
		create_tween().tween_property(_bars, ^"position:y", target, move_time)
	else:
		_bars.position.y = target
