class_name MeleeCombo
extends Node
## Combo de 3 golpes da arma corpo a corpo (04-player): apertar em sequência faz os 3 golpes.
## Cada golpe tem preparação, tempo ativo e recuperação; durante ele Nate anda mais devagar, e os braços batem por
## cima do andar.
## O pai é o Player, que decide quando o combo pode começar e o que o interrompe.

enum Phase { NONE, WINDUP, ACTIVE, RECOVERY }

## Animações dos 3 golpes, feitas para o tempo de golpe do facão; outras armas mudam a velocidade.
@export var hit_animations: Array[AnimationData] = []

var weapon: MeleeWeaponData
var phase := Phase.NONE

var _index := -1
var _attack: AttackData
var _direction := Vector3.FORWARD
var _phase_left := 0.0
var _queued := false
var _window_left := 0.0
var _already_hit: Array[Node3D] = []
var _rng := RandomNumberGenerator.new()

@onready var _player: Player = get_parent()


func is_busy() -> bool:
	return phase != Phase.NONE


## Na recuperação, a esquiva pode cancelar o golpe (04-player).
func in_recovery() -> bool:
	return phase == Phase.RECOVERY


## Direção do golpe atual, no chão.
func direction() -> Vector3:
	return _direction


## Aperto do botão de ataque: começa um golpe ou guarda o próximo do combo.
func press() -> void:
	if weapon == null:
		return
	if is_busy():
		_queued = true
	else:
		_start(_index + 1 if _window_left > 0.0 and _index + 1 < _hit_count() else 0)


## Para o combo na hora (esquiva, golpe levado, morte). O próximo aperto começa do 1º golpe.
func cancel() -> void:
	phase = Phase.NONE
	_index = -1
	_queued = false
	_window_left = 0.0
	_player.show_swing(false)
	_player.stop_overlay()


## Avança o golpe.
func update(delta: float) -> void:
	_window_left = maxf(_window_left - delta, 0.0)
	if _window_left == 0.0 and not is_busy():
		_index = -1
	if not is_busy():
		return
	_phase_left -= delta
	match phase:
		Phase.WINDUP:
			if _phase_left <= 0.0:
				_enter(Phase.ACTIVE, _attack.active)
				_player.show_swing(true)
		Phase.ACTIVE:
			Strike.hit_area(_attack, _player, _player.global_position, _direction, Hurtbox.Faction.ENEMY, _already_hit, _build_hit)
			if _phase_left <= 0.0:
				_enter(Phase.RECOVERY, _attack.recovery)
				_player.show_swing(false)
		Phase.RECOVERY:
			if _phase_left <= 0.0:
				_finish()


func _start(index: int) -> void:
	_index = index
	_queued = false
	_window_left = 0.0
	_attack = weapon.combo_hit(index, Balance.combat)
	_direction = _player.assisted_aim()
	_already_hit.clear()
	_enter(Phase.WINDUP, _attack.windup)
	var animation := hit_animations[index]
	_player.play_overlay(animation, animation.length / _attack.total_time(), true)
	AudioManager.play(&"swing", _player.global_position)


func _finish() -> void:
	phase = Phase.NONE
	if _queued and _index + 1 < _hit_count():
		_start(_index + 1)
		return
	_player.stop_overlay()
	if _index + 1 < _hit_count():
		_window_left = Balance.player.combo_window
	else:
		_index = -1


func _enter(new_phase: Phase, duration: float) -> void:
	phase = new_phase
	_phase_left = duration


func _hit_count() -> int:
	return Balance.combat.combo_knockbacks.size()


func _build_hit(receiver: Node3D) -> Hit:
	var hit := Damage.roll(_attack.damage_points, _player.damage_bonus(), Balance.player.critical_chance + weapon.critical_bonus, Balance.combat, _rng)
	hit.attacker = _player
	hit.knockback = _attack.knockback
	if _index == _hit_count() - 1 and weapon.third_effect >= 0:
		hit.effect = weapon.third_effect
		hit.effect_duration = weapon.third_effect_duration
	if weapon.cooldown_cut > 0.0:
		_player.spells.cut_cooldowns(weapon.cooldown_cut)
	var away := receiver.global_position - _player.global_position
	away.y = 0.0
	hit.direction = away.normalized() if not away.is_zero_approx() else _direction
	return hit
