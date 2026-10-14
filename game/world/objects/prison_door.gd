class_name PrisonDoor
extends Interactable
## Porta da Grande Prisão (08-mapa, 07-chefes/boiuna): abre ao interagir com o muiraquitã inteiro (o Selo). A laje
## desce para dentro do chão. Na luta, ela fecha atrás de Nate, trancada, e só abre de novo quando a luta recomeça.

## Quanto a laje desce, em blocos, e em quanto tempo, em segundos.
@export var drop := 0.0
@export var move_time := 0.0
## Brilho do muiraquitã em relevo na laje.
@export var emblem_color := Color.WHITE
@export var emblem_glow := 0.0

## Trancada durante a luta: não abre nem com o Selo.
var locked := false

var _open := false
var _tween: Tween

@onready var _slab: BlockModel = $Slab
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	super._ready()
	for part in [&"emblem", &"emblem_back"]:
		_slab.set_part_glow(part, emblem_color, emblem_glow)


func can_interact() -> bool:
	return not _open and not locked


# Sem o Selo, a pedra não se mexe (o muiraquitã ainda tem a lasca faltando).
func interact() -> void:
	if not GameState.has_seal():
		AudioManager.play(&"wall_firm", global_position)
		return
	_mark_done()
	open()


func open(animated := true) -> void:
	_set_open(true, animated)


func close() -> void:
	_set_open(false, true)


func is_open() -> bool:
	return _open


func _restore_done() -> void:
	_set_open(true, false)


func _set_open(on: bool, animated: bool) -> void:
	if on == _open and animated:
		return
	_open = on
	_collision.set_deferred(&"disabled", on)
	var height := -drop if on else 0.0
	if not animated or not is_inside_tree():
		_slab.position.y = height
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_slab, ^"position:y", height, move_time)
	AudioManager.play(&"door_open", global_position)
