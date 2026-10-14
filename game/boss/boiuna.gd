class_name Boiuna
extends Node3D
## A Boiúna, o chefe final (07-chefes/boiuna): uma cobra colossal de blocos que sai do fosso no centro da arena. O
## corpo é uma fila de gomos numa curva, do fundo do fosso até a nuca, e a cabeça olha para Nate. Na fase 1 ela ataca
## de frente (o bote, a varrida de cauda e o cuspe de escuridão); cada parte da vida derrubada a deixa atordoada, e a
## parte seguinte só cai depois que um pilar acende para cada parte derrubada (até lá, aparece "imune"). Na fase 2 ela
## some na escuridão e ataca de emboscada e em cerco. A arena (BoiunaArena) diz quando ela acorda, troca de fase e é
## selada; nas cenas, ela faz o que a arena pede (play_scripted). Os números vêm do BoiunaData.

## Uma parte da vida da fase 1 caiu: ela fica atordoada.
signal part_broken
## A vida da fase 2 acabou.
signal defeated

enum Phase { ASLEEP, ONE, TWO, SEALED }
enum State { HIDDEN, EMERGE, IDLE, WINDUP, ACTIVE, REST, RETURN, STUNNED, SCRIPTED }
enum Attack { BITE, TAIL, SPIT, AMBUSH, RING }
## As cenas: debater-se no alto (a troca de fase), mergulhar no fosso e ser puxada para o fundo (a prisão fechando).
enum Scripted { THRASH, DIVE, SEAL }

const CRITICAL_POPUP := preload("res://combat/critical_popup.tscn")
const IMMUNE_POPUP := preload("res://combat/immune_popup.tscn")
## Quantos gomos o corpo e a cauda têm, no máximo (o maior cerco pede uns 45), e em quantos pontos as curvas são
## medidas.
const MAX_SEGMENTS := 64
const MAX_TAIL_SEGMENTS := 24
const CURVE_STEPS := 24
## Direções em volta de Nate onde a emboscada pode surgir.
const AMBUSH_DIRECTIONS := 12

@export var data: BoiunaData
## O chão da arena no plano (x e z), em blocos, e o meio lado do fosso: o cuspe e a emboscada ficam no chão.
@export var arena_rect := Rect2()
@export var pit_half_size := 0.0

var phase := Phase.ASLEEP
var state := State.HIDDEN
## Pilares ativos (a arena conta): deixam a próxima parte da vida cair e encurtam a espera entre os ataques.
var pillars_active := 0

var _state_left := 0.0
var _state_time := 0.0
var _clock := 0.0
var _kind := Attack.BITE
var _last_kind := -1
var _attack: AttackData
var _origin := Vector3.ZERO
var _direction := Vector3.FORWARD
var _targets: Array[Vector3] = []
var _markers: Array[WarningMarker] = []
var _already_hit: Array[Node3D] = []
var _pools: Array[DarkPool] = []
var _spat := false
var _attack_clock := 0.0
var _turn := 0
var _scripted := Scripted.THRASH
var _rng := RandomNumberGenerator.new()
# Medidas da cabeça ampliada, em blocos: o comprimento e a distância da nuca até os olhos.
var _head_length := 0.0
var _eye_distance := 0.0
# A pose: a nuca (o meio da cabeça atrás, onde o corpo encaixa), para onde a cabeça olha, a boca, a garganta
# inchada e o brilho dos olhos; de onde a cabeça partiu no estado atual.
var _nape := Vector3.ZERO
var _look := Vector3.FORWARD
var _jaw := 0.0
var _swell := 0.0
var _eye_glow := 0.0
var _from := Vector3.ZERO
var _ring_center := Vector3.ZERO
var _ring_start := 0.0
var _ring_radius := 0.0
# A cauda: o ângulo em volta do fosso, quanto ela já subiu (erguida) e quanto dela está no chão (varrendo).
var _tail_out := false
var _tail_angle := 0.0
var _tail_rise := 0.0
var _tail_extent := 0.0
var _anchor := Vector3.ZERO
var _flash_left := 0.0
var _immune_left := 0.0
var _alpha := 1.0
var _segments: Array[MeshInstance3D] = []
var _tail_segments: Array[MeshInstance3D] = []
var _segment_material: StandardMaterial3D
var _jaw_part: Node3D

@onready var health: Health = $Health
@onready var status: StatusEffects = $StatusEffects
@onready var _head: BlockModel = $Head
@onready var _body: Node3D = $Body
@onready var _tail: Node3D = $Tail
@onready var _body_hurtbox: Hurtbox = $BodyHurtbox
@onready var _head_hurtbox: Hurtbox = $HeadHurtbox
@onready var _status_visuals: StatusVisuals = $StatusVisuals


func _ready() -> void:
	_rng.randomize()
	_head.model = data.head_model
	_head.top_level = true
	_jaw_part = _head.get_part(&"jaw")
	for box in data.head_model.boxes:
		if box.name == &"head":
			_head_length = -box.position.z / BoxData.PIXELS_PER_BLOCK * data.model_scale
		elif box.name == &"eye_r":
			_eye_distance = -(box.position.z + box.size.z / 2.0) / BoxData.PIXELS_PER_BLOCK * data.model_scale
	_body_hurtbox.radius = data.body_hurt_radius
	_head_hurtbox.radius = data.head_hurt_radius
	_head_hurtbox.top_level = true
	_status_visuals.top_level = true
	_status_visuals.fit(0.0)
	_build_segments()
	sleep()


## Dorme no fundo do fosso, com a vida cheia: antes da luta e quando ela recomeça (Nate morreu).
func sleep() -> void:
	phase = Phase.ASLEEP
	pillars_active = 0
	_end_attack()
	_clear_pools()
	status.clear()
	health.reset(data.parts * data.part_health)
	_enter(State.HIDDEN, 0.0)
	remove_from_group(&"enemies")


## Acorda e a luta começa: sai do fosso, na fase 1; na fase 2 (Nate voltou depois de morrer nela), fica escondida na
## escuridão até o primeiro ataque.
func wake(at_phase_2: bool) -> void:
	add_to_group(&"enemies")
	if at_phase_2:
		start_phase_2()
		return
	phase = Phase.ONE
	health.reset(data.parts * data.part_health)
	_look = _flat_toward(_player_spot())
	_enter(State.EMERGE, data.emerge_time)
	_splash()
	AudioManager.play(&"boiuna_roar", global_position)
	Events.screen_shake.emit(data.roar_shake, data.roar_shake_time)


## A fase 2: uma barra só de vida, e ela começa escondida na escuridão.
func start_phase_2() -> void:
	phase = Phase.TWO
	status.clear()
	health.reset(data.phase_2_health)
	_turn = 0
	_attack_clock = data.ambush_every - data.phase_2_first_delay
	_enter(State.HIDDEN, 0.0)
	add_to_group(&"enemies")


## Nas cenas da arena: debater-se no alto, mergulhar no fosso ou ser puxada para o fundo pelas correntes, em
## [param seconds] segundos. Selada, ela não volta mais.
func play_scripted(kind: Scripted, seconds: float) -> void:
	_end_attack()
	status.clear()
	_scripted = kind
	_from = _nape if state != State.HIDDEN else global_position + Vector3.DOWN * data.depth
	_enter(State.SCRIPTED, seconds)
	if kind == Scripted.DIVE or kind == Scripted.SEAL:
		_splash()
	if kind == Scripted.SEAL:
		phase = Phase.SEALED
		remove_from_group(&"enemies")


## Fora do fosso e lutando: Nate está em combate e a vida dele não volta (02-core-loop).
func is_engaged() -> bool:
	return phase == Phase.ONE or phase == Phase.TWO


## Partes da vida da fase 1 já derrubadas.
func parts_broken() -> int:
	return floori(float(health.max_value - health.value) / data.part_health)


## A próxima parte da vida só cai depois que um pilar acende para cada parte derrubada.
func is_locked() -> bool:
	return phase == Phase.ONE and parts_broken() > pillars_active


## Para onde a ajuda de mira de Nate puxa: a cabeça no chão ou o corpo no fosso; longe de tudo quando nada dela pode
## ser ferido.
func aim_point() -> Vector3:
	var group := Hurtbox.group_for(Hurtbox.Faction.ENEMY)
	if _head_hurtbox.is_in_group(group):
		return _head_hurtbox.global_position
	if _body_hurtbox.is_in_group(group):
		return _body_hurtbox.global_position
	return Vector3.INF


## Onde as correntes de luz dos pilares a prendem: o corpo, logo acima do fosso (escondida, dentro dele).
func chain_anchor() -> Vector3:
	return _anchor if _body.visible else global_position + Vector3.DOWN * data.model_scale


func take_hit(hit: Hit) -> void:
	if not is_engaged() or state in [State.HIDDEN, State.EMERGE, State.SCRIPTED]:
		return
	# Os efeitos de status não pegam (o atordoar dela vem só das partes da vida).
	if hit.effect >= 0:
		_show_immune()
	var points := hit.points
	if phase == Phase.ONE:
		# A parte cai inteira e para no fim; a seguinte espera um pilar aceso.
		var lowest := health.max_value - (parts_broken() + (0 if is_locked() else 1)) * data.part_health
		points = mini(points, health.value - lowest)
	if points <= 0:
		if hit.points > 0:
			_show_immune()
		return
	var broken := parts_broken()
	health.damage(points)
	var where := _hit_point()
	if hit.critical:
		CriticalPopup.spawn(CRITICAL_POPUP, get_parent(), where, points)
	AudioManager.play(&"hit_critical" if hit.critical else &"hit_heavy" if hit.knockback == AttackData.Knockback.LONG else &"hit", where)
	AudioManager.play(&"boiuna_hurt", where)
	_flash_left = data.hurt_flash_time
	if phase == Phase.ONE and parts_broken() > broken:
		_stun()
	elif phase == Phase.TWO and health.is_dead():
		_end_attack()
		defeated.emit()


func _physics_process(delta: float) -> void:
	_state_left -= delta
	_state_time += delta
	_clock += delta
	_immune_left = maxf(_immune_left - delta, 0.0)
	if phase == Phase.TWO and state != State.SCRIPTED:
		_attack_clock += delta
	match state:
		State.EMERGE, State.RETURN:
			if _state_left <= 0.0:
				_settle()
		State.IDLE:
			if _state_left <= 0.0 and _player_ready():
				_start_attack(_pick_attack())
		State.HIDDEN:
			if phase == Phase.TWO and _attack_clock >= data.ambush_every and _player_ready():
				_attack_clock = 0.0
				var ring := data.phase_2_rings[_turn % data.phase_2_rings.size()]
				_turn += 1
				_start_attack(Attack.RING if ring else Attack.AMBUSH)
		State.WINDUP:
			_windup()
		State.ACTIVE:
			_active()
		State.REST, State.STUNNED:
			if _state_left <= 0.0:
				_from = _nape
				_enter(State.RETURN, data.head_return_time)
	_pose(delta)
	var shown := _is_shown()
	_place_head(shown)
	_place_body(shown)
	_place_tail()
	_update_hurtboxes()
	_update_glow(delta)
	_update_see_through(delta)


# Depois de sair do fosso ou de voltar ao lugar: na fase 1, espera o próximo ataque (menos a cada pilar aceso); na
# fase 2, some de novo na escuridão.
func _settle() -> void:
	_tail_out = false
	if phase == Phase.ONE:
		_enter(State.IDLE, data.intervals[mini(pillars_active, data.intervals.size() - 1)])
	else:
		_enter(State.HIDDEN, 0.0)


# Fase 1: um dos três ataques, nunca o mesmo duas vezes seguidas.
func _pick_attack() -> Attack:
	var choices: Array[Attack] = [Attack.BITE, Attack.TAIL, Attack.SPIT]
	choices.erase(_last_kind)
	return choices[_rng.randi() % choices.size()]


func _start_attack(kind: Attack) -> void:
	_kind = kind
	_last_kind = kind
	_already_hit.clear()
	_spat = false
	_from = _nape
	var spot := _player_spot()
	match kind:
		Attack.BITE:
			# A linha sai do fosso e passa um pouco de onde Nate está.
			_origin = global_position
			_direction = _flat_toward(spot)
			_attack = data.bite.duplicate()
			_attack.reach = _flat(spot - _origin).length() + data.lunge_overshoot
			_show_marker(0, _origin, _direction)
		Attack.TAIL:
			_origin = global_position
			_direction = _flat_toward(spot)
			_attack = data.tail_sweep
			_tail_out = true
			_tail_angle = _angle_of(_direction) + deg_to_rad(_attack.angle / 2.0)
			_tail_rise = 0.0
			_tail_extent = 0.0
			_show_marker(0, _origin, _direction)
		Attack.SPIT:
			_attack = data.spit
			_targets = _spit_targets(spot)
			_direction = _flat_toward(spot)
			for i in _targets.size():
				_show_marker(i, _targets[i], Vector3.FORWARD)
		Attack.AMBUSH:
			# Os olhos aparecem na borda da Luz Ancestral, e a linha vai deles até um pouco depois de Nate.
			_origin = _ambush_point(spot)
			_direction = _flat(spot - _origin).normalized()
			_attack = data.ambush.duplicate()
			_attack.reach = _flat(spot - _origin).length() + data.lunge_overshoot
			_nape = _origin - _direction * _eye_distance + Vector3.UP * data.head_rest_height
			_look = _direction
			_from = _nape
			_show_marker(0, _origin, _direction)
		Attack.RING:
			_attack = data.ring
			_ring_center = spot
			_ring_start = _rng.randf() * TAU
			_ring_radius = _attack.reach
			_origin = _ring_center
			_show_marker(0, _ring_center, Vector3.FORWARD)
	# Todo golpe tem o som de aviso próprio, e os olhos brilham antes de qualquer golpe.
	AudioManager.play(_attack.warning_sound, _nape)
	_enter(State.WINDUP, _attack.windup)


func _windup() -> void:
	var progress := _progress()
	for marker in _markers:
		if marker.visible:
			marker.set_progress(progress)
	if _kind == Attack.SPIT and not _spat and _state_left <= data.spit_flight:
		_spat = true
		_throw_spit()
	if _state_left > 0.0:
		return
	for marker in _markers:
		marker.hide_attack()
	_from = _nape
	_enter(State.ACTIVE, _attack.active)
	match _kind:
		Attack.SPIT:
			var middle := Vector3.ZERO
			for target in _targets:
				Strike.hit_area(_attack, self, target, Vector3.FORWARD, Hurtbox.Faction.PLAYER, _already_hit, _build_hit)
				_spawn_pool(target)
				middle += target / _targets.size()
			AudioManager.play(_attack.strike_sound, middle)
		Attack.TAIL:
			AudioManager.play(_attack.strike_sound, global_position + _direction * data.tail_length / 2.0)
			Events.screen_shake.emit(data.slam_shake, data.slam_shake_time)
		_:
			AudioManager.play(_attack.strike_sound, _origin + _direction * _attack.reach)


func _active() -> void:
	match _kind:
		Attack.BITE, Attack.AMBUSH, Attack.TAIL:
			Strike.hit_area(_attack, self, _origin, _direction, Hurtbox.Faction.PLAYER, _already_hit, _build_hit)
		Attack.RING:
			Strike.hit_area(_attack, self, _ring_center, Vector3.FORWARD, Hurtbox.Faction.PLAYER, _already_hit, _build_hit)
	if _state_left > 0.0:
		return
	_from = _nape
	if _kind == Attack.BITE or _kind == Attack.AMBUSH:
		# A cabeça bate no chão e fica lá: a janela para bater nela.
		Events.screen_shake.emit(data.slam_shake, data.slam_shake_time)
		_enter(State.REST, _attack.recovery)
	else:
		_enter(State.RETURN, _attack.recovery)


# Uma parte da vida caiu: ela ruge e desaba na frente do fosso, tonta, por um tempo.
func _stun() -> void:
	_end_attack()
	_direction = _flat_toward(_player_spot())
	_from = _nape
	status.immune = false
	status.apply(StatusEffects.Effect.STUN, data.stun_time)
	status.immune = true
	_enter(State.STUNNED, data.stun_time)
	AudioManager.play(&"boiuna_roar", _nape)
	Events.screen_shake.emit(data.roar_shake, data.roar_shake_time)
	part_broken.emit()


func _end_attack() -> void:
	for marker in _markers:
		marker.hide_attack()
	_swell = 0.0
	_spat = false
	_tail_out = false


# O golpe dela em Nate: o bote empurra para a frente da linha; a cauda e o cerco, para fora.
func _build_hit(receiver: Node3D) -> Hit:
	var hit := Hit.new()
	hit.attacker = self
	hit.player_damage = _attack.player_damage
	hit.knockback = _attack.knockback
	var away := _flat(receiver.global_position - (_ring_center if _kind == Attack.RING else global_position))
	var line := _kind == Attack.BITE or _kind == Attack.AMBUSH
	hit.direction = _direction if line or away.is_zero_approx() else away.normalized()
	return hit


# --- A pose ---

# Onde a cabeça quer ficar em cada estado, para onde ela olha, a boca, a garganta e os olhos.
func _pose(delta: float) -> void:
	var center := global_position
	var spot := _player_spot()
	var progress := _progress()
	var want := _nape
	var look := _look
	var exact := true
	var jaw := 0.0
	var swell := 0.0
	var eye := data.eye_glow
	match state:
		State.HIDDEN:
			want = center + Vector3.DOWN * data.depth
			eye = 0.0
		State.EMERGE:
			want = (center + Vector3.DOWN * data.depth / 2.0).lerp(_idle_nape(spot), _ease_out(progress))
			look = _look_from(want, spot)
			jaw = sin(progress * PI)
		State.IDLE:
			want = _idle_nape(spot)
			look = _look_from(want, spot)
			exact = false
		State.WINDUP:
			eye = lerpf(data.eye_glow, data.eye_warning_glow, progress)
			match _kind:
				Attack.BITE:
					want = center - _direction * data.coil_back + Vector3.UP * (data.head_height + data.coil_rise)
					look = _look_from(want, _origin + _direction * _attack.reach)
					jaw = progress
					exact = false
				Attack.TAIL:
					want = _idle_nape(spot)
					look = _look_from(want, spot)
					exact = false
					_tail_rise = _ease_out(progress)
				Attack.SPIT:
					var middle := Vector3.ZERO
					for target in _targets:
						middle += target / _targets.size()
					want = center + _direction * data.head_reach + Vector3.UP * (data.head_height + data.coil_rise)
					look = _look_from(want, middle)
					swell = 0.0 if _spat else progress
					jaw = 1.0 if _spat else 0.0
					exact = false
				Attack.AMBUSH:
					# Os olhos na borda da luz; a cabeça recua um pouco e se ergue, armando o bote.
					want = _origin - _direction * (_eye_distance + data.coil_back * progress) \
						+ Vector3.UP * (data.head_rest_height + data.coil_rise * progress)
					look = _direction
					jaw = progress
				Attack.RING:
					_ring_radius = lerpf(_attack.reach, data.ring_closed_radius, progress * progress)
					var angle := _ring_start + data.ring_turns * TAU * progress
					want = _ring_point(angle, _ring_radius)
					look = _ring_tangent(angle)
		State.ACTIVE:
			eye = data.eye_warning_glow
			match _kind:
				Attack.BITE, Attack.AMBUSH:
					want = _from.lerp(_lunge_end(), _ease_in(progress))
					look = _direction
					jaw = 1.0
				Attack.TAIL:
					want = _idle_nape(spot)
					look = _look_from(want, spot)
					exact = false
					_tail_extent = 1.0
					_tail_angle = _angle_of(_direction) + deg_to_rad(_attack.angle) * (0.5 - progress)
				Attack.SPIT:
					want = _nape
					jaw = 1.0 - progress
				Attack.RING:
					var angle := _ring_start + data.ring_turns * TAU
					want = _ring_point(angle, _ring_radius)
					look = _ring_tangent(angle)
		State.REST:
			want = _lunge_end()
			look = _direction
		State.STUNNED:
			var lying := center + _direction * (pit_half_size + data.head_reach) + Vector3.UP * data.head_rest_height
			want = _from.lerp(lying, _ease_out(minf(_state_time / data.head_return_time, 1.0)))
			look = _direction
			jaw = data.stunned_jaw
			eye = data.eye_stunned_glow
		State.RETURN:
			if phase == Phase.ONE:
				want = _from.lerp(_idle_nape(spot), _ease_out(progress))
				look = _look.lerp(_look_from(want, spot), progress).normalized()
			else:
				# Na fase 2, ela volta para a escuridão: pelo chão até o fosso, na primeira metade, e para o fundo.
				var at_pit := center + Vector3.UP * data.head_rest_height
				if progress < 0.5:
					want = _from.lerp(at_pit, _ease_out(progress * 2.0))
				else:
					want = at_pit.lerp(center + Vector3.DOWN * data.depth, _ease_in(progress * 2.0 - 1.0))
				var back := _flat(center - _from)
				look = back.normalized() if not back.is_zero_approx() else _look
			if _kind == Attack.TAIL:
				_tail_extent = 1.0 - progress
		State.SCRIPTED:
			match _scripted:
				Scripted.THRASH:
					# Debatendo-se no alto, presa às correntes: a cabeça roda e a boca abre e fecha.
					var turn := _clock * TAU / data.thrash_time
					var side := Vector3(sin(turn), 0.0, cos(turn))
					var high := center + Vector3.UP * (data.head_height + data.coil_rise) + side * data.thrash_sway
					want = _from.lerp(high, _ease_out(minf(_state_time / data.head_return_time, 1.0)))
					look = (Vector3.UP + side).normalized()
					jaw = (1.0 + sin(turn)) / 2.0
					eye = data.eye_warning_glow
				Scripted.DIVE, Scripted.SEAL:
					# Selada, ela ainda se debate enquanto as correntes a puxam para o fundo.
					var turn := _clock * TAU / data.thrash_time
					var shake := Vector3(sin(turn), 0.0, cos(turn)) * data.thrash_sway * (1.0 - progress) \
						if _scripted == Scripted.SEAL else Vector3.ZERO
					want = _from.lerp(center + Vector3.DOWN * data.depth, _ease_in(progress)) + shake
					look = _look.lerp(Vector3.DOWN, progress)
					jaw = data.stunned_jaw if _scripted == Scripted.SEAL else 0.0
					eye = data.eye_glow * (1.0 - progress)
	if exact:
		_nape = want
		_look = look.normalized() if not look.is_zero_approx() else _look
	else:
		var follow := 1.0 - exp(-data.head_follow * delta)
		_nape = _nape.lerp(want, follow)
		var turned := _look.lerp(look, follow)
		_look = turned.normalized() if not turned.is_zero_approx() else _look
	_jaw = jaw
	_swell = swell
	_eye_glow = eye


func _is_shown() -> bool:
	if state == State.HIDDEN:
		return false
	return not (state == State.SCRIPTED and _scripted != Scripted.THRASH and _state_left <= 0.0)


# A cabeça parada: inclinada do centro do fosso para o lado de Nate, no alto, balançando de leve.
func _idle_nape(spot: Vector3) -> Vector3:
	var toward := _flat_toward(spot)
	var side := toward.cross(Vector3.UP)
	var sway := sin(_clock * TAU / data.sway_time) * data.sway
	return global_position + toward * data.head_reach + side * sway + Vector3.UP * data.head_height


# Para onde a cabeça olha, de [param from] até Nate: quase reto, só um pouco para baixo.
func _look_from(from: Vector3, spot: Vector3) -> Vector3:
	var toward := spot - from
	toward.y *= data.look_pitch
	return toward.normalized() if not toward.is_zero_approx() else _look


# Onde a nuca fica no fim do bote: a ponta do focinho no fim da linha, a cabeça deitada no chão (no bote, fora do
# fosso).
func _lunge_end() -> Vector3:
	var along := _attack.reach - _head_length
	if _kind == Attack.BITE:
		along = maxf(along, pit_half_size)
	return _origin + _direction * along + Vector3.UP * data.head_rest_height


func _ring_point(angle: float, radius: float) -> Vector3:
	return _ring_center + Vector3.FORWARD.rotated(Vector3.UP, angle) * radius + Vector3.UP * data.head_rest_height


func _ring_tangent(angle: float) -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, angle + PI / 2.0)


func _place_head(shown: bool) -> void:
	_head.visible = shown
	_status_visuals.global_position = _nape + Vector3.UP * data.model_scale
	if not shown:
		return
	var up := Vector3.UP if absf(_look.dot(Vector3.UP)) < 0.98 else Vector3.BACK
	var swell := 1.0 + _swell * data.throat_swell
	_head.global_transform = Transform3D(Basis.looking_at(_look, up).scaled_local(Vector3(swell, swell, 1.0) * data.model_scale), _nape)
	if _jaw_part:
		_jaw_part.rotation_degrees.x = -_jaw * data.jaw_open


# --- O corpo e a cauda ---

func _build_segments() -> void:
	var model := data.segment_model
	_segment_material = StandardMaterial3D.new()
	_segment_material.albedo_texture = model.texture
	_segment_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_segment_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_segment_material.emission = Color.WHITE
	var mesh := model.boxes[0].build_mesh(Vector2(model.texture.get_size()), model.bevel)
	for i in MAX_SEGMENTS:
		_segments.append(_segment(mesh, _body))
	for i in MAX_TAIL_SEGMENTS:
		_tail_segments.append(_segment(mesh, _tail))


func _segment(mesh: Mesh, parent: Node3D) -> MeshInstance3D:
	var segment := MeshInstance3D.new()
	segment.mesh = mesh
	segment.material_override = _segment_material
	segment.layers = BlockModel.MODEL_LAYER
	segment.top_level = true
	segment.visible = false
	parent.add_child(segment)
	return segment


# O corpo: sobe reto do fundo do fosso e faz uma curva até a nuca; no cerco, dá a volta em Nate antes.
func _place_body(shown: bool) -> void:
	_body.visible = shown
	if not shown:
		return
	var center := global_position
	var rim := center + Vector3.UP * data.model_scale / 2.0
	var path := PackedVector3Array([center + Vector3.DOWN * data.depth])
	var ring := _kind == Attack.RING and state in [State.WINDUP, State.ACTIVE]
	if ring:
		var head_angle := _ring_start + data.ring_turns * TAU * (_progress() if state == State.WINDUP else 1.0)
		var entry := _ring_point(head_angle - TAU, _ring_radius)
		_append_curve(path, rim, rim + Vector3.UP * data.model_scale, entry - _ring_tangent(head_angle - TAU) * data.model_scale, entry)
		for i in range(1, CURVE_STEPS + 1):
			path.append(_ring_point(head_angle - TAU + TAU * i / CURVE_STEPS, _ring_radius))
	else:
		# Os pontos de controle nos terços: sobe do fosso e chega à nuca por trás da cabeça.
		var rise := maxf(_nape.y - rim.y, 0.0)
		_append_curve(path, rim, rim + Vector3.UP * rise / 2.0, _nape - _look * rim.distance_to(_nape) / 3.0, _nape)
	_anchor = _point_along(path, data.depth + data.model_scale)
	_lay_segments(_segments, path, data.body_thickness)


# A cauda, só na varrida: sobe do fosso e se ergue com a ponta no alto; depois deita no chão e varre o setor.
func _place_tail() -> void:
	var shown := _tail_out and state in [State.WINDUP, State.ACTIVE, State.RETURN]
	_tail.visible = shown
	if not shown:
		return
	var center := global_position
	var out := Vector3.FORWARD.rotated(Vector3.UP, _tail_angle)
	var thickness := data.tail_thickness * data.model_scale
	var rim := center + out * (pit_half_size - thickness.x / 2.0)
	var path := PackedVector3Array([center + Vector3.DOWN * data.depth, rim + Vector3.DOWN * thickness.x])
	if state == State.WINDUP:
		var tip := rim + out * thickness.x + Vector3.UP * (data.tail_height * _tail_rise - data.depth * (1.0 - _tail_rise))
		_append_curve(path, rim, rim + Vector3.UP * data.tail_height * _tail_rise / 2.0, tip - out * thickness.x, tip)
	else:
		var lying := Vector3.UP * thickness.y / 2.0
		var end := center + out * (pit_half_size + data.tail_length * _tail_extent)
		_append_curve(path, rim + lying, rim + out + lying, end - out + lying, end + lying)
	_lay_segments(_tail_segments, path, data.tail_thickness)


# Uma curva de Bézier, de [param a] a [param d], no fim do caminho.
func _append_curve(path: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for i in CURVE_STEPS + 1:
		var t := float(i) / CURVE_STEPS
		var u := 1.0 - t
		path.append(a * u * u * u + b * 3.0 * u * u * t + c * 3.0 * u * t * t + d * t * t * t)


# Os gomos ao longo do caminho (do fundo até a ponta), a partir da ponta; a grossura vai de [param thickness].x no
# fundo até [param thickness].y na ponta, em tamanhos de gomo, e cada gomo fica a uma parte do tamanho dele do
# seguinte, para os finos da ponta também se encostarem.
func _lay_segments(segments: Array[MeshInstance3D], path: PackedVector3Array, thickness: Vector2) -> void:
	var total := 0.0
	for i in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	var along := total
	for segment in segments:
		segment.visible = along >= 0.0 and total > 0.0
		if not segment.visible:
			continue
		var size := lerpf(thickness.x, thickness.y, along / total) * data.model_scale
		var step := data.segment_spacing * size
		var at := _point_along(path, along)
		var ahead := _point_along(path, minf(along + step / 2.0, total)) - _point_along(path, maxf(along - step / 2.0, 0.0))
		segment.global_transform = Transform3D(_basis_along(ahead).scaled_local(Vector3.ONE * size), at)
		along -= step


# O ponto do caminho a [param distance] blocos do começo.
static func _point_along(path: PackedVector3Array, distance: float) -> Vector3:
	var walked := 0.0
	for i in range(1, path.size()):
		var piece := path[i - 1].distance_to(path[i])
		if walked + piece >= distance and piece > 0.0:
			return path[i - 1].lerp(path[i], (distance - walked) / piece)
		walked += piece
	return path[path.size() - 1]


static func _basis_along(direction: Vector3) -> Basis:
	if direction.is_zero_approx():
		return Basis.IDENTITY
	var up := Vector3.UP if absf(direction.normalized().dot(Vector3.UP)) < 0.98 else Vector3.BACK
	return Basis.looking_at(direction, up)


# --- Golpes ---

func _show_marker(index: int, origin: Vector3, forward: Vector3) -> void:
	while _markers.size() <= index:
		var marker := WarningMarker.new()
		add_child(marker)
		_markers.append(marker)
	_markers[index].show_attack(_attack, origin, forward)


# Os círculos do cuspe: um em Nate e os outros em volta dele, todos no chão da arena, fora do fosso.
func _spit_targets(spot: Vector3) -> Array[Vector3]:
	var targets: Array[Vector3] = [_keep_on_floor(spot, _attack.reach)]
	var first := _rng.randf() * TAU
	for i in range(1, data.spit_count):
		var angle := first + TAU * (i - 1) / maxi(data.spit_count - 1, 1)
		targets.append(_keep_on_floor(spot + Vector3.FORWARD.rotated(Vector3.UP, angle) * data.spit_spread, _attack.reach))
	return targets


# As gotas voam da boca até os círculos e caem quando o aviso acaba.
func _throw_spit() -> void:
	var mouth := _nape + _look * _head_length
	AudioManager.play(&"boiuna_spit", mouth)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = data.pool_color
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * data.spit_size
	mesh.material = material
	for target in _targets:
		var blob := MeshInstance3D.new()
		blob.mesh = mesh
		blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		get_parent().add_child(blob)
		blob.global_position = mouth
		var flight := func(t: float) -> void:
			blob.global_position = mouth.lerp(target, t) + Vector3.UP * data.spit_arc * 4.0 * t * (1.0 - t)
			blob.rotation = Vector3(data.spit_turns.x, data.spit_turns.y, 0.0) * TAU * t
		var tween := blob.create_tween()
		tween.tween_method(flight, 0.0, 1.0, data.spit_flight)
		tween.tween_callback(blob.queue_free)


func _spawn_pool(where: Vector3) -> void:
	var pool := DarkPool.new()
	get_parent().add_child(pool)
	pool.global_position = where + Vector3.UP * WarningMarker.FLOOR_OFFSET
	pool.start(_attack, data.pool_color, data.pool_time, data.pool_fade_time)
	_pools.append(pool)


func _clear_pools() -> void:
	for pool in _pools:
		if is_instance_valid(pool):
			pool.clear()
	_pools.clear()


# A emboscada surge na borda da Luz Ancestral, de um lado sorteado que fique no chão da arena; com Nate num canto,
# do lado do fosso.
func _ambush_point(spot: Vector3) -> Vector3:
	var radius := Balance.player.light_radius
	var rect := arena_rect.grow(-data.head_hurt_radius)
	var choices: Array[Vector3] = []
	for i in AMBUSH_DIRECTIONS:
		var point := spot + Vector3.FORWARD.rotated(Vector3.UP, TAU * i / AMBUSH_DIRECTIONS) * radius
		if rect.has_point(Vector2(point.x, point.z)) and not _over_pit(point, 0.0):
			choices.append(point)
	if choices.is_empty():
		return _keep_on_floor(spot - _flat_toward(spot) * radius, data.head_hurt_radius)
	return choices[_rng.randi() % choices.size()]


# O ponto mais perto dentro do chão da arena, a [param margin] blocos das paredes e da beira do fosso.
func _keep_on_floor(point: Vector3, margin: float) -> Vector3:
	var rect := arena_rect.grow(-margin)
	var offset := Vector2(clampf(point.x, rect.position.x, rect.end.x), clampf(point.z, rect.position.y, rect.end.y))
	offset -= Vector2(global_position.x, global_position.z)
	var keep := pit_half_size + margin
	if absf(offset.x) < keep and absf(offset.y) < keep:
		if absf(offset.x) >= absf(offset.y):
			offset.x = keep * (signf(offset.x) if offset.x != 0.0 else 1.0)
		else:
			offset.y = keep * signf(offset.y)
	return Vector3(global_position.x + offset.x, global_position.y, global_position.z + offset.y)


func _over_pit(point: Vector3, margin: float) -> bool:
	return absf(point.x - global_position.x) < pit_half_size + margin and absf(point.z - global_position.z) < pit_half_size + margin


func _splash() -> void:
	SpellEffects.burst(get_parent(), global_position, data.pool_color, data.splash_radius, data.splash_look)
	AudioManager.play(&"boiuna_emerge", global_position)


# --- Vida, sinais e brilho ---

# O corpo, em volta do fosso, só na fase 1; a cabeça, quando está no chão (o bote, atordoada) ou, na fase 2, quando
# aparece para atacar.
func _update_hurtboxes() -> void:
	var out := is_engaged() and state not in [State.HIDDEN, State.EMERGE, State.SCRIPTED]
	_set_hurtbox(_body_hurtbox, out and phase == Phase.ONE)
	var low := state in [State.REST, State.STUNNED] or (phase == Phase.TWO and state in [State.WINDUP, State.ACTIVE])
	_set_hurtbox(_head_hurtbox, out and low)
	var middle := _nape + _look * _head_length / 2.0
	_head_hurtbox.global_position = Vector3(middle.x, global_position.y, middle.z)


func _set_hurtbox(box: Hurtbox, on: bool) -> void:
	var group := Hurtbox.group_for(Hurtbox.Faction.ENEMY)
	if on and not box.is_in_group(group):
		box.add_to_group(group)
	elif not on and box.is_in_group(group):
		box.remove_from_group(group)


func _update_glow(delta: float) -> void:
	_flash_left = maxf(_flash_left - delta, 0.0)
	var flash := 1.0 if _flash_left > 0.0 else 0.0
	_head.set_glow(flash)
	_segment_material.emission_enabled = flash > 0.0
	_segment_material.emission_energy_multiplier = flash
	for eye in [&"eye_r", &"eye_l"]:
		_head.set_part_glow(eye, data.eye_color, _eye_glow)


# Quando ela fica entre a câmera e Nate, fica meio transparente, para ele não sumir atrás dela: a cabeça ou um gomo
# na frente dele, na tela.
func _update_see_through(delta: float) -> void:
	var target := 1.0
	var camera := get_viewport().get_camera_3d()
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if camera and player and _head.visible and camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var chest := player.global_position + Vector3.UP * data.see_through_height
		var forward := -camera.global_basis.z
		var depth := forward.dot(chest - camera.global_position)
		var spot := camera.unproject_position(chest)
		var pixels := get_viewport().get_visible_rect().size.y / camera.size
		var covers := func(point: Vector3, radius: float) -> bool:
			return forward.dot(point - camera.global_position) < depth \
				and camera.unproject_position(point).distance_to(spot) < (radius + data.see_through_margin) * pixels
		if covers.call(_nape + _look * _head_length / 2.0, _head_length / 2.0):
			target = data.see_through_alpha
		else:
			for segment in _segments + _tail_segments:
				if segment.is_visible_in_tree() and covers.call(segment.global_position, segment.scale.x / 2.0):
					target = data.see_through_alpha
					break
	var alpha := move_toward(_alpha, target, delta / data.see_through_time)
	if alpha == _alpha:
		return
	_alpha = alpha
	_head.set_alpha(alpha)
	_segment_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS if alpha < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
	_segment_material.albedo_color.a = alpha


# "Imune", em cinza, com a batida seca (03-regras): um efeito de status que não pega, ou a parte travada.
func _show_immune() -> void:
	if _immune_left > 0.0:
		return
	_immune_left = data.immune_wait
	CriticalPopup.spawn(IMMUNE_POPUP, get_parent(), _hit_point(), 0)
	AudioManager.play(&"immune", _hit_point())


# Onde o número do crítico e o imune aparecem: em cima da cabeça, se ela está no chão; senão, do corpo.
func _hit_point() -> Vector3:
	if _head_hurtbox.is_in_group(Hurtbox.group_for(Hurtbox.Faction.ENEMY)):
		return _head_hurtbox.global_position + Vector3.UP * data.model_scale
	return global_position + Vector3.UP * data.head_height


# --- Ajudas ---

func _enter(new_state: State, duration: float) -> void:
	state = new_state
	_state_left = duration
	_state_time = 0.0


func _progress() -> float:
	var total := _state_time + _state_left
	return clampf(_state_time / total, 0.0, 1.0) if total > 0.0 else 1.0


func _player_ready() -> bool:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	return player != null and not player.is_dead() and not player.is_cinematic()


func _player_spot() -> Vector3:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return global_position + Vector3.FORWARD
	return Vector3(player.global_position.x, global_position.y, player.global_position.z)


func _flat_toward(spot: Vector3) -> Vector3:
	var toward := _flat(spot - global_position)
	return toward.normalized() if not toward.is_zero_approx() else Vector3.FORWARD


static func _angle_of(direction: Vector3) -> float:
	return atan2(-direction.x, -direction.z)


static func _flat(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z)


static func _ease_in(t: float) -> float:
	return t * t


static func _ease_out(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)
