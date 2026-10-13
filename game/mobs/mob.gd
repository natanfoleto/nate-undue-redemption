class_name Mob
extends CharacterBody3D
## Mob (06-mobs): nota Nate quando o vê, persegue, cerca e ataca na sua vez da fila, e volta para casa
## se o perde de vista. Golpes, avisos e recuo seguem o 03-regras; os números vêm do MobData e do Balance.

signal died(mob: Mob)

enum State { IDLE, CHASE, WINDUP, ACTIVE, RECOVERY, STAGGER, RETURN, DEAD }

const CRITICAL_POPUP := preload("res://combat/critical_popup.tscn")

@export var data: MobData
## Identificador único no mapa: quem morre continua morto (02-core-loop). Vazio nos mobs que não são salvos,
## como as ondas das arenas.
@export var save_id: StringName

var state := State.IDLE
## Invocado por um Necromante: some quando Nate volta depois de morrer, e se desfaz quando quem invocou morre.
var summoned := false

var _home := Vector3.ZERO
var _home_facing := Vector3.FORWARD
var _facing := Vector3.FORWARD
var _target: Node3D
var _last_seen := Vector3.ZERO
var _unseen_time := 0.0
var _state_left := 0.0
var _cooldown_left := 0.0
var _attack_origin := Vector3.ZERO
var _attack_direction := Vector3.FORWARD
var _already_hit: Array[Node3D] = []
var _push_velocity := Vector3.ZERO
var _push_left := 0.0
var _strikes_done := 0
# O golpe em andamento e se o próximo é o segundo (os mobs com dois golpes alternam).
var _attack: AttackData
var _next_is_second := false
var _fall_speed := 0.0

@onready var health: Health = $Health
@onready var status: StatusEffects = $StatusEffects
@onready var _model: BlockModel = $BlockModel
@onready var _animator: ModelAnimator = $BlockModel/ModelAnimator
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _marker: WarningMarker = $WarningMarker
@onready var _health_bar: HealthBar3D = $HealthBar
@onready var _status_visuals: StatusVisuals = $StatusVisuals
@onready var _agent: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	if SaveSystem.has_record(SaveSystem.KILLED, save_id):
		queue_free()
		return
	add_to_group(&"enemies")
	# O corpo não gira: só o modelo olha para os lados.
	_home = global_position
	_home_facing = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	_facing = _home_facing
	rotation.y = 0.0
	_hurtbox.radius = data.hurt_radius
	_model.model = data.model
	_model.scale = Vector3.ONE * data.model_scale
	_health_bar.position.y = _model_height() + _health_bar.lift
	_status_visuals.fit(_model_height())
	health.reset(data.health)
	health.died.connect(_die)
	Events.player_respawned.connect(reset)
	_animator.play(data.idle_animation)


## Volta para casa com a vida cheia: a morte de Nate reinicia os inimigos vivos (02-core-loop).
func reset() -> void:
	if state == State.DEAD:
		return
	if summoned:
		queue_free()
		return
	_end_attack()
	global_position = _home
	_facing = _home_facing
	velocity = Vector3.ZERO
	_push_left = 0.0
	_cooldown_left = 0.0
	_unseen_time = 0.0
	health.reset(data.health)
	status.clear()
	_health_bar.visible = false
	state = State.IDLE
	_animator.play(data.idle_animation)


func take_hit(hit: Hit) -> void:
	if state == State.DEAD:
		return
	health.damage(hit.points)
	if hit.critical:
		CriticalPopup.spawn(CRITICAL_POPUP, get_parent(), global_position + Vector3.UP * _model_height(), hit.points)
	if health.is_dead():
		return
	_health_bar.show_value(health.value, health.max_value)
	if hit.effect >= 0:
		status.apply(hit.effect, hit.effect_duration)
	if CombatRules.knockback_affects(data.weight, hit.knockback):
		# Interrompido: perde o golpe que preparava e fica um tempo sem agir.
		_push(hit.direction, Balance.combat.knockback_distance(hit.knockback))
		_end_attack()
		_enter(State.STAGGER, Balance.combat.interrupt_time)
		_animator.play(data.hurt_animation)
	elif (state == State.IDLE or state == State.RETURN) and hit.attacker == _target:
		# Nate bateu de longe, fora da vista: o mob vai até onde ele estava.
		_last_seen = _target.global_position
		_enter(State.CHASE, 0.0)


## Dano da queimadura (03-regras): em pontos.
func take_status_damage(_hearts: int, points: int) -> void:
	if state == State.DEAD:
		return
	health.damage(points)
	if not health.is_dead():
		_health_bar.show_value(health.value, health.max_value)


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	_state_left -= delta
	_target = get_tree().get_first_node_in_group(&"player") as Node3D
	# Atordoado: não se move nem ataca, e perde o golpe que preparava (03-regras).
	if status.has(StatusEffects.Effect.STUN):
		if state in [State.WINDUP, State.ACTIVE, State.RECOVERY]:
			_end_attack()
			_enter(State.CHASE, 0.0)
		velocity = Vector3.ZERO
		_apply_push(delta)
		_move(delta)
		return
	match state:
		State.IDLE:
			_idle()
		State.CHASE:
			_chase(delta)
		State.WINDUP:
			_windup()
		State.ACTIVE:
			_active()
		State.RECOVERY:
			_recovery()
		State.STAGGER:
			_stagger()
		State.RETURN:
			_return_home(delta)
	_apply_push(delta)
	_move(delta)
	_model.rotation.y = atan2(-_facing.x, -_facing.z)


# Direção para chegar a um ponto pelo caminho do mapa de navegação (12-tecnico): contorna paredes e pilares e
# sobe pelas escadas. Sem mapa, ou já perto, vai em linha reta.
func _path_direction(target: Vector3) -> Vector3:
	var straight := _flat(target - global_position)
	var direct := straight.normalized() if not straight.is_zero_approx() else _facing
	if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
		return direct
	_agent.target_position = target
	var step := _flat(_agent.get_next_path_position() - global_position)
	return step.normalized() if not step.is_zero_approx() else direct


# Anda no chão com a velocidade dos estados e cai pela gravidade fora dele (o relevo).
func _move(delta: float) -> void:
	if is_on_floor():
		_fall_speed = 0.0
	else:
		_fall_speed -= Balance.world.gravity * delta
	velocity.y = _fall_speed
	move_and_slide()


func _apply_push(delta: float) -> void:
	if _push_left > 0.0:
		_push_left -= delta
		velocity = _push_velocity


func _idle() -> void:
	velocity = Vector3.ZERO
	if _can_see_target():
		_enter(State.CHASE, 0.0)


func _chase(delta: float) -> void:
	if _can_see_target():
		_unseen_time = 0.0
		_last_seen = _target.global_position
	else:
		_unseen_time += delta
		if _unseen_time >= Balance.combat.give_up_time:
			_enter(State.RETURN, 0.0)
			return
	var offset := _flat(_last_seen - global_position)
	var distance := offset.length()
	if _special_action(offset, delta):
		return
	var limit := Balance.combat.max_attackers
	var can_attack := _cooldown_left == 0.0 and _unseen_time == 0.0
	var next := _next_attack()
	if can_attack and distance <= next.reach and AttackQueue.try_enter(self, limit):
		_strikes_done = 0
		_start_attack(offset)
		return
	if not offset.is_zero_approx():
		_facing = offset.normalized()
	# Com vez na fila, chega ao alcance do golpe; sem vez, cerca Nate e espera.
	var stand := next.reach if can_attack and AttackQueue.has_room(self, limit) else data.wait_distance
	if distance > stand:
		_facing = _path_direction(_last_seen)
		velocity = _facing * _speed()
		_animator.play(data.walk_animation)
	else:
		velocity = Vector3.ZERO
		_animator.play(data.idle_animation)


# O próximo golpe: o primeiro, ou o segundo quando é a vez dele.
func _next_attack() -> AttackData:
	return data.second_attack if _next_is_second and data.second_attack else data.attack


func _start_attack(offset: Vector3) -> void:
	var attack := _next_attack()
	var second := attack != data.attack
	_attack = attack
	if data.second_attack:
		_next_is_second = not _next_is_second
	_attack_origin = global_position
	_attack_direction = offset.normalized()
	_facing = _attack_direction
	_already_hit.clear()
	velocity = Vector3.ZERO
	if attack.warning == AttackData.Warning.GROUND_MARK:
		_marker.show_attack(attack, _attack_origin, _attack_direction)
	_enter(State.WINDUP, attack.windup)
	_animator.play(data.second_windup_animation if second else data.windup_animation)


# Aviso (03-regras): golpe comum com pose e brilho branco; golpe forte com a marca no chão enchendo.
func _windup() -> void:
	var attack := _attack
	velocity = Vector3.ZERO
	var progress := clampf(1.0 - _state_left / attack.windup, 0.0, 1.0) if attack.windup > 0.0 else 1.0
	if attack.warning == AttackData.Warning.GROUND_MARK:
		_marker.set_progress(progress)
	else:
		_model.set_glow(progress)
	if _state_left <= 0.0:
		_marker.hide_attack()
		_model.set_glow(0.0)
		_enter(State.ACTIVE, attack.active)
		_animator.play(data.second_attack_animation if attack != data.attack else data.attack_animation)


func _active() -> void:
	var attack := _attack
	velocity = _attack_direction * (attack.lunge / attack.active) if attack.active > 0.0 else Vector3.ZERO
	Strike.hit_area(attack, self, _attack_origin, _attack_direction, Hurtbox.Faction.PLAYER, _already_hit, _build_hit)
	if _state_left <= 0.0:
		velocity = Vector3.ZERO
		_end_strike()


# Fim do tempo ativo: o próximo golpe da sequência (com o próprio aviso) ou a recuperação.
func _end_strike() -> void:
	_strikes_done += 1
	if _strikes_done < data.attack_count and _can_see_target():
		_start_attack(_flat(_target.global_position - global_position))
		return
	_enter(State.RECOVERY, _attack.recovery)


## Ação própria de um tipo de mob durante a perseguição (o Necromante recua e invoca). Verdadeiro quando ela
## tomou conta do quadro.
func _special_action(_offset: Vector3, _delta: float) -> bool:
	return false


func _recovery() -> void:
	velocity = Vector3.ZERO
	if _state_left <= 0.0:
		_end_attack()
		_cooldown_left = _attack.cooldown
		_enter(State.CHASE, 0.0)


func _stagger() -> void:
	velocity = Vector3.ZERO
	if _state_left <= 0.0:
		_enter(State.CHASE if _can_see_target() else State.RETURN, 0.0)


func _return_home(delta: float) -> void:
	if _can_see_target():
		_enter(State.CHASE, 0.0)
		return
	var offset := _flat(_home - global_position)
	if offset.length() <= data.move_speed * delta:
		global_position = _home
		velocity = Vector3.ZERO
		_facing = _home_facing
		_enter(State.IDLE, 0.0)
		_animator.play(data.idle_animation)
		return
	_facing = _path_direction(_home)
	velocity = _facing * _speed()
	_animator.play(data.walk_animation)


func _speed() -> float:
	return data.move_speed * status.speed_share()


## Se desfaz na hora (os esqueletos invocados, quando o Necromante morre).
func crumble() -> void:
	if state != State.DEAD:
		health.damage(health.value)


func _die() -> void:
	_end_attack()
	status.clear()
	_enter(State.DEAD, 0.0)
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = HitShape.WORLD_LAYER
	_hurtbox.queue_free()
	remove_from_group(&"enemies")
	_health_bar.visible = false
	_animator.play(data.death_animation)
	died.emit(self)
	Events.enemy_died.emit(self)
	await get_tree().create_timer(data.death_animation.length, false).timeout
	queue_free()


func _build_hit(receiver: Node3D) -> Hit:
	var hit := Hit.new()
	hit.attacker = self
	hit.hearts = _attack.damage_hearts
	hit.knockback = _attack.knockback
	hit.effect = _attack.effect
	hit.effect_duration = _attack.effect_duration
	var away := _flat(receiver.global_position - global_position)
	hit.direction = away.normalized() if not away.is_zero_approx() else _attack_direction
	return hit


func _push(direction: Vector3, distance: float) -> void:
	var time := Balance.combat.knockback_time
	if distance <= 0.0 or time <= 0.0:
		return
	_push_velocity = _flat(direction).normalized() * distance / time
	_push_left = time


func _end_attack() -> void:
	AttackQueue.leave(self)
	_marker.hide_attack()
	_model.set_glow(0.0)


func _enter(new_state: State, duration: float) -> void:
	state = new_state
	_state_left = duration


# Nate à vista: dentro da percepção, sem parede no meio e vivo.
func _can_see_target() -> bool:
	if _target == null or _target.call(&"is_dead"):
		return false
	var offset := _flat(_target.global_position - global_position)
	if offset.length() > data.perception:
		return false
	return not HitShape.wall_between(get_world_3d().direct_space_state, global_position, _target.global_position)


func _model_height() -> float:
	return _model.height() * _model.scale.y


static func _flat(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z)
