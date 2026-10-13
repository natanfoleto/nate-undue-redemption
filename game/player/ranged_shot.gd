class_name RangedShot
extends Node
## Tiro da arma à distância (04-player): segurar puxa até a força total, soltar atira; soltar antes cancela.
## Enquanto puxa, Nate anda à metade da velocidade e não ataca de perto. Depois do tiro há uma recuperação.
## O pai é o Player.

enum Phase { NONE, DRAWING, RECOVERY }

const PROJECTILE := preload("res://combat/projectile.tscn")

## Braços puxando (para por cima do andar), segurando puxado e soltando.
@export var draw_animation: AnimationData
@export var release_animation: AnimationData

var weapon: RangedWeaponData
var phase := Phase.NONE

var _drawn := 0.0
var _phase_left := 0.0
var _rng := RandomNumberGenerator.new()

@onready var _player: Player = get_parent()


func is_busy() -> bool:
	return phase != Phase.NONE


func is_drawing() -> bool:
	return phase == Phase.DRAWING


## Se já puxou até a força total.
func is_full() -> bool:
	return is_drawing() and _drawn >= weapon.draw_time


func press() -> void:
	if weapon == null or is_busy():
		return
	phase = Phase.DRAWING
	_drawn = 0.0
	_player.play_overlay(draw_animation, draw_animation.length / weapon.draw_time)
	_player.show_ranged_weapon(true)


func release() -> void:
	if not is_drawing():
		return
	if not is_full():
		cancel()
		return
	_fire()
	phase = Phase.RECOVERY
	_phase_left = Balance.player.shot_recovery
	_player.play_overlay(release_animation, release_animation.length / Balance.player.shot_recovery)


## Para o tiro na hora (esquiva, golpe levado, morte).
func cancel() -> void:
	phase = Phase.NONE
	_player.stop_overlay()
	_player.show_ranged_weapon(false)
	_player.set_ranged_glow(false)


func update(delta: float) -> void:
	match phase:
		Phase.DRAWING:
			var was_full := is_full()
			_drawn += delta
			if is_full() and not was_full:
				_player.set_ranged_glow(true) # Sinal da força total (10-arte-audio).
		Phase.RECOVERY:
			_phase_left -= delta
			if _phase_left <= 0.0:
				cancel()


func _fire() -> void:
	var attack := weapon.shot()
	var direction := _player.assisted_aim()
	var projectile := PROJECTILE.instantiate() as Projectile
	_player.get_parent().add_child(projectile)
	projectile.global_position = _player.shot_origin()
	(projectile.get_node(^"BlockModel") as BlockModel).model = weapon.projectile_model
	projectile.pierce = weapon.pierce
	projectile.launch(attack, direction, Hurtbox.Faction.ENEMY, _build_hit.bind(attack, direction))
	_player.set_ranged_glow(false)


func _build_hit(_receiver: Node3D, attack: AttackData, direction: Vector3) -> Hit:
	var hit := Damage.roll(attack.damage_points, _player.damage_bonus(), Balance.player.critical_chance, Balance.combat, _rng)
	hit.attacker = _player
	hit.knockback = attack.knockback
	hit.direction = direction
	hit.effect = weapon.effect
	hit.effect_duration = weapon.effect_duration
	return hit
