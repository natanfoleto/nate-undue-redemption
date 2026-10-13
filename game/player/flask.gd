class_name Flask
extends Node
## Frasco (04-player, 05-itens): a única cura. Beber leva um tempo, com Nate andando mais devagar, sem atacar
## nem esquivar; a cura vem no fim, mesmo se ele levar um golpe, e a carga nunca se perde. Recarrega no
## santuário e quando Nate volta depois de morrer. O pai é o Player.

signal changed(charges: int, max_charges: int)

## A pose de beber, por cima do andar.
@export var drink_animation: AnimationData
## A moringa na mão de Nate enquanto ele bebe.
@export var model: ModelData

var charges := 0
var max_charges := 0

var _left := 0.0

@onready var _player: Player = get_parent()


func is_drinking() -> bool:
	return _left > 0.0


func press() -> void:
	if is_drinking() or not GameState.has_flask() or charges <= 0:
		return
	charges -= 1
	_left = Balance.player.flask_time
	_player.play_overlay(drink_animation, drink_animation.length / _left)
	_player.show_flask(true)
	changed.emit(charges, max_charges)


func update(delta: float) -> void:
	if not is_drinking():
		return
	_left -= delta
	if _left <= 0.0:
		_left = 0.0
		_player.heal(Balance.player.flask_heal)
		_stop()


## Para de beber sem curar (morte).
func cancel() -> void:
	if is_drinking():
		_left = 0.0
		_stop()


## Enche todas as cargas.
func refill() -> void:
	max_charges = GameState.flask_charges()
	charges = max_charges
	changed.emit(charges, max_charges)


## Depois de uma melhoria de carga: a carga nova chega cheia (05-itens).
func refill_new() -> void:
	var new_max := GameState.flask_charges()
	charges += new_max - max_charges
	max_charges = new_max
	changed.emit(charges, max_charges)


func _stop() -> void:
	_player.stop_overlay()
	_player.show_flask(false)
