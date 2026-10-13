class_name StatusEffects
extends Node
## Efeitos de status (03-regras): atordoado, lento, veneno e queimadura. O mesmo efeito não acumula: aplicar
## de novo renova a duração. Efeitos diferentes valem ao mesmo tempo. Quem sofre é o pai, que precisa ter
## take_status_damage(hearts: int, points: int); Nate perde corações, os mobs perdem pontos.

signal changed

enum Effect { STUN, SLOW, POISON, BURN }

# Folga para os tempos que terminam juntos no mesmo quadro (o veneno que age no fim, o último tique da queimadura).
const EPSILON := 0.0001

## Imune a tudo (o chefe), salvo onde a luta for feita para isso.
@export var immune := false
## Nunca fica atordoado (Nate).
@export var stun_proof := false

var _left: Dictionary[Effect, float] = {}
var _poison_elapsed := 0.0
var _burn_tick_left := 0.0


## Aplica um efeito por [param duration] segundos. Devolve falso quando o efeito não pega (imune).
func apply(effect: Effect, duration: float, duration_share := 1.0) -> bool:
	if immune or (effect == Effect.STUN and stun_proof) or duration <= 0.0:
		return false
	var fresh := not _left.has(effect)
	_left[effect] = duration * duration_share
	if effect == Effect.POISON:
		_poison_elapsed = 0.0
	if effect == Effect.BURN and fresh:
		_burn_tick_left = Balance.status.burn_interval
	if fresh:
		changed.emit()
	return true


func has(effect: Effect) -> bool:
	return _left.has(effect)


func active() -> Array[Effect]:
	return _left.keys()


## Tira todos os efeitos (Nate voltando depois de morrer, o mob voltando para casa).
func clear() -> void:
	if not _left.is_empty():
		_left.clear()
		changed.emit()


## Quanto da velocidade sobra: lento anda à metade (11-balanceamento).
func speed_share() -> float:
	return Balance.status.slow_speed_share if has(Effect.SLOW) else 1.0


func _physics_process(delta: float) -> void:
	if _left.is_empty():
		return
	var rules := Balance.status
	var receiver := get_parent()
	if has(Effect.BURN):
		_burn_tick_left -= delta
		if _burn_tick_left <= EPSILON:
			_burn_tick_left += rules.burn_interval
			receiver.call(&"take_status_damage", 0, rules.burn_damage)
	if has(Effect.POISON):
		_poison_elapsed += delta
		# O veneno só age se durar até o fim da espera; com a Água equipada, acaba antes (11-balanceamento).
		if _poison_elapsed >= rules.poison_delay - EPSILON:
			_left.erase(Effect.POISON)
			receiver.call(&"take_status_damage", rules.poison_hearts, 0)
			changed.emit()
	var expired := false
	for effect: Effect in _left.keys():
		_left[effect] -= delta
		if _left[effect] <= EPSILON:
			_left.erase(effect)
			expired = true
	if expired:
		changed.emit()
