class_name Necromancer
extends Mob
## O Necromante (06-mobs/necromante.md): mantém distância, lança a praga de longe e invoca esqueletos. Quando
## morre, os esqueletos que invocou se desfazem. Invocar não conta na fila de ataque (06-mobs/README.md).

const PROJECTILE := preload("res://combat/projectile.tscn")

var _summons: Array[Mob] = []
var _summon_cooldown_left := 0.0
var _summoning := false
var _summon_spots: Array[Vector3] = []
var _summon_markers: Array[WarningMarker] = []
var _fired := false


func _ready() -> void:
	super._ready()
	if is_queued_for_deletion():
		return
	var necromancer := data as NecromancerData
	for i in necromancer.summon_count:
		var marker := WarningMarker.new()
		add_child(marker)
		_summon_markers.append(marker)


func reset() -> void:
	_summon_cooldown_left = 0.0
	_summoning = false
	super.reset()


func _physics_process(delta: float) -> void:
	_summon_cooldown_left = maxf(_summon_cooldown_left - delta, 0.0)
	super._physics_process(delta)


# Recua quando Nate chega perto e invoca quando pode; a praga segue a fila como os outros golpes.
func _special_action(offset: Vector3, _delta: float) -> bool:
	var necromancer := data as NecromancerData
	# Sem tipo no parâmetro: um esqueleto já liberado não pode ser passado como Mob.
	_summons.assign(_summons.filter(func(mob: Variant) -> bool: return is_instance_valid(mob) and mob.state != State.DEAD))
	if _unseen_time == 0.0 and _summon_cooldown_left == 0.0 and _summons.size() < necromancer.summon_max:
		_start_summon(offset)
		return true
	if offset.length() < necromancer.retreat_distance and _unseen_time == 0.0:
		_facing = offset.normalized()
		velocity = -_facing * _speed()
		_animator.play(data.walk_animation)
		return true
	return false


func _start_summon(offset: Vector3) -> void:
	var necromancer := data as NecromancerData
	_summoning = true
	if not offset.is_zero_approx():
		_facing = offset.normalized()
	velocity = Vector3.ZERO
	# As marcas ficam dos dois lados do Necromante, onde os esqueletos vão surgir (aviso de área).
	_summon_spots.clear()
	var side := _facing.cross(Vector3.UP).normalized()
	var count := mini(necromancer.summon_count, necromancer.summon_max - _summons.size())
	for i in count:
		var side_sign := 1.0 if i % 2 == 0 else -1.0
		var spot := global_position + side * side_sign * necromancer.summon_distance * (1 + i / 2)
		_summon_spots.append(spot)
		_summon_markers[i].show_attack(necromancer.summon, spot, _facing)
	_enter(State.WINDUP, necromancer.summon.windup)
	_animator.play(necromancer.summon_animation)


func _windup() -> void:
	if not _summoning:
		super._windup()
		return
	var summon := (data as NecromancerData).summon
	velocity = Vector3.ZERO
	var progress := clampf(1.0 - _state_left / summon.windup, 0.0, 1.0) if summon.windup > 0.0 else 1.0
	for marker in _summon_markers:
		marker.set_progress(progress)
	if _state_left <= 0.0:
		_finish_summon()


func _finish_summon() -> void:
	var necromancer := data as NecromancerData
	for marker in _summon_markers:
		marker.hide_attack()
	for spot in _summon_spots:
		var skeleton := necromancer.summon_scene.instantiate() as Mob
		skeleton.summoned = true
		# A posição vem antes de entrar na cena: é a casa para onde o esqueleto volta.
		skeleton.position = (get_parent() as Node3D).to_local(spot)
		skeleton.rotation.y = atan2(-_facing.x, -_facing.z)
		get_parent().add_child(skeleton)
		_summons.append(skeleton)
	_summoning = false
	_summon_cooldown_left = necromancer.summon.cooldown
	_enter(State.RECOVERY, necromancer.summon.recovery)
	_animator.play(data.idle_animation)


# A praga sai no primeiro quadro do tempo ativo, mirada em Nate.
func _active() -> void:
	velocity = Vector3.ZERO
	if not _fired:
		_fired = true
		_fire_plague()
	if _state_left <= 0.0:
		_fired = false
		_end_strike()


func _recovery() -> void:
	if _summoning:
		return
	super._recovery()


func _fire_plague() -> void:
	var necromancer := data as NecromancerData
	var aim := _attack_direction
	if _target:
		var offset := _flat(_target.global_position - global_position)
		if not offset.is_zero_approx():
			aim = offset.normalized()
	_facing = aim
	var count := necromancer.plague_count
	for i in count:
		var angle := 0.0 if count == 1 else lerpf(-necromancer.plague_fan_angle / 2.0, necromancer.plague_fan_angle / 2.0, float(i) / (count - 1))
		var direction := aim.rotated(Vector3.UP, deg_to_rad(angle))
		var projectile := PROJECTILE.instantiate() as Projectile
		get_parent().add_child(projectile)
		projectile.global_position = global_position + Vector3.UP * necromancer.plague_height
		var model := projectile.get_node(^"BlockModel") as BlockModel
		model.model = necromancer.plague_model
		model.set_glow(necromancer.plague_glow, necromancer.plague_color)
		projectile.launch(data.attack, direction, Hurtbox.Faction.PLAYER, _plague_hit.bind(direction))


func _plague_hit(_receiver: Node3D, direction: Vector3) -> Hit:
	var necromancer := data as NecromancerData
	var hit := Hit.new()
	hit.attacker = self
	hit.hearts = data.attack.damage_hearts
	hit.knockback = data.attack.knockback
	hit.direction = direction
	hit.effect = necromancer.plague_effect
	hit.effect_duration = necromancer.plague_effect_duration
	return hit


func _end_attack() -> void:
	super._end_attack()
	_fired = false
	if _summoning:
		_summoning = false
		_summon_cooldown_left = 0.0
	for marker in _summon_markers:
		marker.hide_attack()


func _die() -> void:
	for mob in _summons:
		if is_instance_valid(mob):
			mob.crumble()
	_summons.clear()
	super._die()
