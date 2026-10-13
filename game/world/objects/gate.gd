class_name Gate
extends StaticBody3D
## Portão (08-mapa): grades que descem para dentro do chão quando abrem. Fechado, bloqueia a passagem,
## os tiros e a visão dos mobs. Abre pela alavanca ligada a ele ou pela arena.

## Alavanca que abre o portão (vazio nas arenas, que abrem e fecham por conta própria).
@export var lever: Lever
## Outras alavancas: com elas, o portão só abre quando todas foram puxadas (o segredo do Arco marajoara).
@export var extra_levers: Array[Lever] = []
## Quanto as grades descem, em blocos, e em quanto tempo, em segundos.
@export var drop := 0.0
@export var move_time := 0.0
## Começa aberto (as arenas fecham os portões só quando a luta começa).
@export var starts_open := false

var _open := false

@onready var _bars: Node3D = $Bars
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	for each in _levers():
		each.pulled.connect(_on_lever_pulled)
	if starts_open or (lever != null and _all_pulled()):
		_set_open(true, false)


func _on_lever_pulled() -> void:
	if _all_pulled():
		open()


# Pelo jogo salvo, e não pelas alavancas, que podem ficar prontas depois do portão.
func _all_pulled() -> bool:
	return _levers().all(func(each: Lever) -> bool: return SaveSystem.has_record(SaveSystem.OPENED, each.save_id))


func _levers() -> Array[Lever]:
	var all: Array[Lever] = []
	if lever:
		all.append(lever)
	all.append_array(extra_levers)
	return all


func open(animated := true) -> void:
	_set_open(true, animated)


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
