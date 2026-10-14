class_name Player
extends CharacterBody3D
## Nate (04-player): anda, olha para onde anda, mira, dá o dash, luta e leva golpes. Os números vêm do Balance.
## Segura na mão o item do espaço escolhido da barra fixa: com a arma de perto, o botão de atacar golpeia (e, durante o
## dash, guarda o golpe do dash); com a de longe, segurar o botão de usar puxa e soltar atira; com a poção, segurar o
## botão de usar bebe. O combo, o tiro, as magias e a poção ficam nos componentes filhos MeleeCombo, RangedShot,
## SpellCaster e Flask.

## Ações dos 5 espaços da barra, na ordem.
const HOTBAR_ACTIONS: Array[StringName] = [&"hotbar_1", &"hotbar_2", &"hotbar_3", &"hotbar_4", &"hotbar_5"]

@export var idle_animation: AnimationData
@export var walk_animation: AnimationData
@export var dash_animation: AnimationData
@export var hurt_animation: AnimationData
@export var death_animation: AnimationData
## Rastro do golpe (10-arte-audio): a meia-lua branca, com a grossura máxima em blocos (para dentro, a partir do
## alcance); o tempo em que ela varre o arco e o tempo em que some, em segundos; e a transparência.
@export var swing_width := 0.0
@export var swing_sweep_time := 0.0
@export var swing_fade_time := 0.0
@export var swing_alpha := 1.0
## Rastro do dash (10-arte-audio): uma cópia translúcida de Nate a cada tanto tempo, que some neste outro tempo, em
## segundos; a cor e a transparência da cópia.
@export var afterimage_interval := 0.0
@export var afterimage_time := 0.0
@export var afterimage_color := Color.WHITE
## Poeira do dash: os cubos que saem dos pés, para trás (os números ficam na cena).
@export var dash_dust: PackedScene
## Cor do muiraquitã aceso e da Luz Ancestral (10-arte-audio).
@export var light_color := Color.WHITE
## Força do brilho do muiraquitã aceso.
@export var amulet_glow := 0.0
## O muiraquitã acordando: brilho e luz a mais no auge do pulso, e a duração, em segundos.
@export var awaken_glow := 0.0
@export var awaken_light := 0.0
@export var awaken_time := 0.0
## Força da Luz Ancestral acesa nas áreas escuras: o lugar escurecido aparece em volta de Nate.
@export var ancestral_light_energy := 0.0

## Direção da mira no chão, de tamanho 1. Os ataques vão nessa direção, puxados pela ajuda de mira.
var aim_direction := Vector3.FORWARD
## Para onde Nate olha, no chão, de tamanho 1.
var facing := Vector3.FORWARD

var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _dash_direction := Vector3.ZERO
var _afterimage_left := 0.0
# O golpe do dash: guardado durante o dash, sai no fim dele; e o tempo desde o último aperto de atacar, para o dash
# logo depois de atacar também virar golpe do dash.
var _dash_strike := false
var _attack_pressed_ago := INF
var _control_left := 0.0
var _hurt_invincible_left := 0.0
var _push_velocity := Vector3.ZERO
var _push_left := 0.0
var _dead := false
var _spawn_position := Vector3.ZERO
var _spawn_facing := Vector3.FORWARD
var _hand_model: BlockModel
var _held: ItemData
var _swing_tween: Tween
var _armor: ArmorData
var _armor_model: BlockModel
var _flask_model: BlockModel
var _cinematic := false
var _boost_share := 0.0
var _boost_left := 0.0
var _regen_wait_left := 0.0
var _regen_progress := 0.0
var _fall_speed := 0.0
var _step_left := 0.0
var _shield: SpellArea

@onready var health: Health = $Health
@onready var status: StatusEffects = $StatusEffects
@onready var spells: SpellCaster = $SpellCaster
@onready var flask: Flask = $Flask
@onready var _model: BlockModel = $BlockModel
@onready var _animator: ModelAnimator = $BlockModel/ModelAnimator
@onready var _aim_arrow: Node3D = $AimArrow
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _melee: MeleeCombo = $MeleeCombo
@onready var _ranged: RangedShot = $RangedShot
@onready var _swing: MeshInstance3D = $Swing
@onready var _light: OmniLight3D = $AncestralLight


func _ready() -> void:
	add_to_group(&"player")
	_spawn_position = global_position
	_spawn_facing = facing
	_hurtbox.radius = Balance.player.hurt_radius
	_equip()
	health.reset(max_health())
	flask.refill()
	($StatusVisuals as StatusVisuals).fit(_model.height())
	_light.omni_range = Balance.player.light_radius
	_light.light_color = light_color
	_light.light_energy = ancestral_light_energy
	_light.visible = false
	_show_amulet()
	GameState.inventory_changed.connect(_on_inventory_changed)
	GameState.hand_changed.connect(_on_hand_changed)
	GameState.upgrades_changed.connect(_on_upgrades_changed)
	GameState.elements_changed.connect(_show_amulet)


func _physics_process(delta: float) -> void:
	if _cinematic:
		velocity = Vector3.ZERO
		_update_animation()
		return
	if _dead:
		velocity = _push_velocity if _push_left > 0.0 else Vector3.ZERO
		_push_left -= delta
		_move(delta)
		return
	_control_left = maxf(_control_left - delta, 0.0)
	_hurt_invincible_left = maxf(_hurt_invincible_left - delta, 0.0)
	_boost_left = maxf(_boost_left - delta, 0.0)
	var in_control := _control_left == 0.0
	var move := _ground_direction(Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")) if in_control else Vector3.ZERO
	if not is_dashing():
		_dash_cooldown_left = maxf(_dash_cooldown_left - delta, 0.0)
	if in_control:
		_read_actions(move, delta)
	_melee.update(delta)
	_ranged.update(delta)
	spells.update(delta)
	flask.update(delta)
	_update_regen(delta)
	if is_dashing():
		_update_dash(delta)
	elif in_control:
		_walk(move * _speed_share(), delta)
	else:
		velocity = Vector3.ZERO
	if _push_left > 0.0:
		_push_left -= delta
		velocity = _push_velocity
	_move(delta)
	_update_steps()
	_update_facing()
	_update_aim(move)
	_update_animation()
	_update_blink()
	_update_light()


func is_dashing() -> bool:
	return _dash_time_left > 0.0


## Vida máxima, em pontos: a de Nate, a das melhorias e a da armadura (05-itens).
func max_health() -> int:
	var stats := Balance.player
	return stats.max_health + GameState.upgrade_count(GameState.HEART_UPGRADE) * stats.upgrade_health + (_armor.extra_health if _armor else 0)


## Bônus de dano (03-regras): a soma dos bônus em %, que hoje vêm só da armadura.
func damage_bonus() -> float:
	return _armor.damage_bonus if _armor else 0.0


## Velocidade de andar: a armadura pesada e a lentidão deixam Nate mais lento, e a Rajada Veloz, mais rápido
## (11-balanceamento).
func move_speed() -> float:
	var boost := 1.0 + (_boost_share if _boost_left > 0.0 else 0.0)
	return (_armor.move_speed if _armor else Balance.player.move_speed) * status.speed_share() * boost


## Rajada Veloz: Nate fica mais rápido por um tempo.
func boost_speed(share: float, duration: float) -> void:
	_boost_share = share
	_boost_left = duration


## Escudo de Areia: enquanto a areia gira, o próximo golpe não tira vida.
func raise_shield(area: SpellArea) -> void:
	_shield = area


func has_shield() -> bool:
	return is_instance_valid(_shield)


# Golpeando, puxando o tiro ou bebendo do frasco, Nate anda mais devagar (04-player).
func _speed_share() -> float:
	if _melee.is_busy():
		return Balance.player.melee_speed_share
	if _ranged.is_drawing():
		return Balance.player.drawing_speed_share
	if flask.is_drinking():
		return Balance.player.flask_speed_share
	return 1.0


## Com a Água equipada, os efeitos em Nate duram menos (05-itens).
static func status_duration_share() -> float:
	return Balance.status.water_duration_share if GameState.has_element_equipped(&"water") else 1.0


## Novo ponto de retorno (02-core-loop): para onde Nate volta ao morrer.
func set_spawn(where: Vector3, spawn_facing: Vector3) -> void:
	_spawn_position = where
	_spawn_facing = spawn_facing
	facing = spawn_facing


## Durante uma cena (a descida do elevador, o santuário), Nate não responde aos botões.
func set_cinematic(on: bool) -> void:
	_cinematic = on
	_melee.cancel()
	_ranged.cancel()
	_aim_arrow.visible = not on
	if on:
		velocity = Vector3.ZERO
		_animator.play(idle_animation)


## Descanso no santuário (02-core-loop): vida e frasco cheios, sem efeitos.
func rest() -> void:
	health.reset(max_health())
	flask.refill()
	status.clear()


## Cura da poção, em pontos.
func heal(amount: int) -> void:
	health.heal(amount)


func is_dead() -> bool:
	return _dead


func is_cinematic() -> bool:
	return _cinematic


## Puxando o tiro.
func is_drawing() -> bool:
	return _ranged.is_drawing()


func is_swinging() -> bool:
	return _melee.is_busy()


## No dash ou logo depois de levar golpe, nada fere Nate (03-regras).
func is_invincible() -> bool:
	return is_dashing() or _hurt_invincible_left > 0.0


## A mira puxada para o inimigo mais próximo dentro do cone da ajuda de mira (04-player).
func assisted_aim() -> Vector3:
	var stats := Balance.player
	var best_offset := Vector3.ZERO
	for enemy: Node3D in get_tree().get_nodes_in_group(&"enemies"):
		var offset := enemy.global_position - global_position
		# Inimigo fora da altura que o golpe alcança (num platô) não puxa a mira.
		if absf(offset.y) > Balance.combat.height_reach:
			continue
		offset.y = 0.0
		if offset.is_zero_approx() or offset.length() > stats.aim_assist_range:
			continue
		# O cone se abre metade para cada lado da mira.
		if rad_to_deg(aim_direction.angle_to(offset)) > stats.aim_assist_angle / 2.0:
			continue
		if best_offset.is_zero_approx() or offset.length() < best_offset.length():
			best_offset = offset
	return aim_direction if best_offset.is_zero_approx() else best_offset.normalized()


## Leva um golpe (03-regras): perde vida, é empurrado, perde o controle e fica invencível um tempo.
func take_hit(hit: Hit) -> void:
	if _dead or is_invincible():
		return
	_wait_regen()
	if has_shield():
		# O escudo segura o golpe inteiro e se desfaz; Nate ainda é empurrado e pisca.
		_shield.finish()
		_shield = null
	else:
		health.damage(hit.player_damage)
		if hit.effect >= 0 and not health.is_dead():
			status.apply(hit.effect, hit.effect_duration, status_duration_share())
	_melee.cancel()
	_ranged.cancel()
	AudioManager.play(&"nate_hurt", global_position)
	if health.is_dead():
		_die()
		return
	_push(hit.direction, Balance.combat.knockback_distance(hit.knockback))
	_control_left = Balance.player.hit_stun
	_hurt_invincible_left = Balance.player.hit_invincibility
	play_animation(hurt_animation, 1.0)


## Dano do veneno (03-regras): em pontos, mas nunca tira o último.
func take_status_damage(amount: int, _points: int) -> void:
	if _dead:
		return
	if amount > 0:
		_wait_regen()
	health.damage(mini(amount, health.value - 1))


## Em combate: algum inimigo está atrás de Nate ou lutando com ele.
func in_combat() -> bool:
	return get_tree().get_nodes_in_group(&"enemies").any(func(enemy: Node) -> bool: return enemy is Mob and (enemy as Mob).is_engaged())


# A vida volta sozinha fora de combate (02-core-loop): sem inimigo atrás de Nate e depois de um tempo sem levar
# dano, uns pontos por segundo.
func _update_regen(delta: float) -> void:
	_regen_wait_left = maxf(_regen_wait_left - delta, 0.0)
	if health.value >= health.max_value or _regen_wait_left > 0.0 or in_combat():
		_regen_progress = 0.0
		return
	_regen_progress += Balance.player.regen_rate * delta
	var whole := floori(_regen_progress)
	if whole > 0:
		_regen_progress -= whole
		health.heal(whole)


# Levou dano: a vida só volta a encher depois de um tempo sem levar outro.
func _wait_regen() -> void:
	_regen_wait_left = Balance.player.regen_delay
	_regen_progress = 0.0


## De onde sai o tiro: o centro de Nate, na altura da mão que segura o estilingue, para o projétil voar
## na linha da mira e não ao lado dela.
func shot_origin() -> Vector3:
	var hand := _model.get_part(&"hand_l")
	var height := hand.global_position.y if hand else global_position.y + 1.0
	return Vector3(global_position.x, height, global_position.z)


func play_animation(animation: AnimationData, speed: float) -> void:
	_animator.restart(animation)
	_animator.speed_scale = speed


func play_overlay(animation: AnimationData, speed: float, from_start := false) -> void:
	_animator.play_overlay(animation, speed, from_start)


func stop_overlay() -> void:
	_animator.stop_overlay()


## O rastro do golpe (10-arte-audio): um arco curto na direção do golpe, durante o tempo ativo; nasce pequeno,
## cresce até o tamanho cheio e some devagar.
func show_swing(on: bool) -> void:
	if _swing_tween:
		_swing_tween.kill()
	var material := _swing.material_override as ShaderMaterial
	if not on:
		_swing_tween = create_tween()
		_swing_tween.tween_method(func(value: float) -> void: material.set_shader_parameter(&"fade", value), swing_alpha, 0.0, swing_fade_time)
		_swing_tween.tween_callback(_swing.hide)
		return
	var direction := _melee.direction()
	_swing.rotation.y = atan2(-direction.x, -direction.z)
	# O 1º golpe e o 3º vão da direita para a esquerda; o 2º volta, da esquerda para a direita (o rastro espelhado).
	_swing.scale = Vector3(-1.0 if _melee.hit_index() == 1 else 1.0, 1.0, 1.0)
	_swing.visible = true
	material.set_shader_parameter(&"fade", swing_alpha)
	_swing_tween = create_tween()
	_swing_tween.tween_method(func(value: float) -> void: material.set_shader_parameter(&"progress", value), 0.0, 1.0, swing_sweep_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Brilho na arma quando o tiro chega à força total (10-arte-audio).
func set_ranged_glow(on: bool) -> void:
	if _hand_model and _ranged.weapon:
		_hand_model.set_glow(1.0 if on else 0.0)


# Os números e a roda do mouse (o direcional no controle) trocam o item da mão, até no meio do dash. Antes da
# interface: a roda do mouse em cima do HUD também troca.
func _input(event: InputEvent) -> void:
	if _dead or _cinematic:
		return
	for i in HOTBAR_ACTIONS.size():
		if event.is_action_pressed(HOTBAR_ACTIONS[i]):
			GameState.select_hand(i)
	if event.is_action_pressed(&"hotbar_next"):
		GameState.select_hand(GameState.hand() + 1)
	elif event.is_action_pressed(&"hotbar_previous"):
		GameState.select_hand(GameState.hand() - 1)


func _read_actions(move: Vector3, delta: float) -> void:
	_attack_pressed_ago += delta
	var attack_pressed := Input.is_action_just_pressed(&"attack")
	if attack_pressed:
		_attack_pressed_ago = 0.0
	# Beber é segurar o botão: soltar antes do fim para de beber, sem gastar a carga.
	if flask.is_drinking():
		if not Input.is_action_pressed(&"use_hold"):
			flask.cancel()
		return
	# O dash cancela a recuperação dos golpes e o tiro; logo depois de apertar atacar, também a preparação do golpe,
	# que vira o golpe do dash (Espaço + clique, em qualquer ordem) (04-player).
	var combo_input := _attack_pressed_ago <= Balance.player.dash_strike_window and _melee.weapon != null
	var can_dash := not is_dashing() and (not _melee.is_busy() or _melee.in_recovery() or combo_input)
	if Input.is_action_just_pressed(&"dodge") and can_dash and is_zero_approx(_dash_cooldown_left):
		_melee.cancel()
		_ranged.cancel()
		_start_dash(move)
		_dash_strike = combo_input
		return
	if is_dashing():
		if attack_pressed and _melee.weapon:
			_dash_strike = true
		return
	if attack_pressed and _melee.weapon and not _ranged.is_busy():
		_melee.press()
	if Input.is_action_just_pressed(&"use_hold") and not _melee.is_busy():
		if _ranged.weapon:
			_ranged.press()
		elif GameState.hand_item() is PotionData and not _ranged.is_busy():
			flask.press()
			return
	# Pelo estado do botão, e não pelo quadro em que foi solto: com o jogo pausado, esse quadro não roda.
	if _ranged.is_drawing() and not Input.is_action_pressed(&"use_hold"):
		_ranged.release()
	var hands_free := not _melee.is_busy() and not _ranged.is_busy()
	if hands_free and GameState.learned_elements().size() > 0:
		if Input.is_action_just_pressed(&"spell_1"):
			spells.press(0)
		if Input.is_action_just_pressed(&"spell_2"):
			spells.press(1)
	if Input.is_action_just_pressed(&"interact") and hands_free:
		var target := _nearest_interactable()
		if target:
			target.interact()


# O objeto mais perto ao alcance da mão.
func _nearest_interactable() -> Interactable:
	var best: Interactable = null
	var best_distance := INF
	for object: Interactable in get_tree().get_nodes_in_group(&"interactables"):
		var offset := object.global_position - global_position
		var distance := Vector2(offset.x, offset.z).length()
		if object.can_interact() and distance <= object.reach and distance < best_distance:
			best = object
			best_distance = distance
	return best


func _walk(move: Vector3, delta: float) -> void:
	var speed := move_speed()
	var rate := speed / Balance.player.acceleration_time
	var ground := Vector3(velocity.x, 0.0, velocity.z).move_toward(move * speed, rate * delta)
	velocity = ground


# Anda no chão com a velocidade dos estados e cai pela gravidade fora dele (o relevo: escadas e beiradas).
func _move(delta: float) -> void:
	if is_on_floor():
		_fall_speed = 0.0
	else:
		_fall_speed -= Balance.world.gravity * delta
	velocity.y = _fall_speed
	move_and_slide()


# Passos: um som a cada tantos blocos andados no chão, conforme o bloco embaixo de Nate (10-arte-audio).
func _update_steps() -> void:
	if not is_on_floor() or is_dashing():
		return
	var moved := Vector2(get_position_delta().x, get_position_delta().z).length()
	if is_zero_approx(moved):
		return
	_step_left -= moved
	if _step_left > 0.0:
		return
	_step_left += AudioManager.rules.step_distance
	AudioManager.play(_step_sound(), global_position)


# Grama e musgo; madeira (tábuas, pontes, a plataforma do elevador); o resto é pedra e terra.
func _step_sound() -> StringName:
	var terrain := get_tree().current_scene.get_node_or_null(^"Terrain") as GridMap
	if terrain == null:
		return &"step_stone"
	var item := terrain.get_cell_item(terrain.local_to_map(terrain.to_local(global_position + Vector3.DOWN * 0.5)))
	if item == GridMap.INVALID_CELL_ITEM:
		return &"step_wood"
	var block := terrain.mesh_library.get_item_name(item)
	if block.begins_with("Grama") or block.ends_with("musgo"):
		return &"step_grass"
	if block in ["Tábuas", "Madeira velha", "Pé de cogumelo", "Tronco"]:
		return &"step_wood"
	return &"step_stone"


# O dash (04-player): Nate se inclina e dispara para a frente, deixando cópias translúcidas e poeira para trás.
func _start_dash(move: Vector3) -> void:
	var stats := Balance.player
	_dash_direction = facing if move.is_zero_approx() else move
	facing = _dash_direction
	_dash_time_left = stats.dash_duration
	_afterimage_left = 0.0
	play_animation(dash_animation, dash_animation.length / stats.dash_duration)
	AudioManager.play(&"dash", global_position)
	_spawn_dust()


# Anda exatamente a distância do dash: o último passo da física só cobre o tempo que faltava.
func _update_dash(delta: float) -> void:
	var stats := Balance.player
	var step := minf(delta, _dash_time_left)
	velocity = _dash_direction * (stats.dash_distance / stats.dash_duration) * (step / delta)
	_dash_time_left -= step
	_afterimage_left -= step
	if _afterimage_left <= 0.0:
		_afterimage_left += afterimage_interval
		_spawn_afterimage()
	if _dash_time_left <= 0.0:
		_dash_time_left = 0.0
		_dash_cooldown_left = _armor.dash_cooldown if _armor and _armor.dash_cooldown > 0.0 else stats.dash_cooldown
		# O golpe do dash: o 3º golpe do combo, na direção do dash.
		if _dash_strike and _melee.weapon:
			_melee.dash_strike(_dash_direction)
		_dash_strike = false


# Uma cópia de Nate parada onde ele está agora, que some aos poucos (10-arte-audio).
func _spawn_afterimage() -> void:
	var ghost := Node3D.new()
	get_tree().current_scene.add_child(ghost)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = afterimage_color
	for part: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		if not part.is_visible_in_tree():
			continue
		var copy := MeshInstance3D.new()
		copy.mesh = part.mesh
		copy.material_override = material
		copy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ghost.add_child(copy)
		copy.global_transform = part.global_transform
	var tween := ghost.create_tween()
	tween.tween_property(material, ^"albedo_color:a", 0.0, afterimage_time)
	tween.tween_callback(ghost.queue_free)


# Poeira dos pés no começo do dash: cubos pequenos que saem para trás e para os lados; a subida vem da cena.
func _spawn_dust() -> void:
	var dust := dash_dust.instantiate() as CPUParticles3D
	dust.direction = -_dash_direction + Vector3.UP * dust.direction.y
	get_tree().current_scene.add_child(dust)
	dust.global_position = global_position
	dust.emitting = true
	dust.finished.connect(dust.queue_free)


func _push(direction: Vector3, distance: float) -> void:
	var time := Balance.combat.knockback_time
	if distance <= 0.0 or time <= 0.0:
		return
	_push_velocity = Vector3(direction.x, 0.0, direction.z).normalized() * distance / time
	_push_left = time


# Durante o golpe, Nate olha para o golpe; puxando o tiro, para a mira; fora disso, para onde anda.
func _update_facing() -> void:
	if _melee.is_busy():
		facing = _melee.direction()
	elif _ranged.is_drawing():
		facing = assisted_aim()
	elif _push_left <= 0.0:
		var ground_velocity := Vector3(velocity.x, 0.0, velocity.z)
		if not ground_velocity.is_zero_approx():
			facing = ground_velocity.normalized()
	_model.rotation.y = atan2(-facing.x, -facing.z)


# Teclado e mouse: na direção do cursor. Controle: na do analógico direito; solto, na do movimento.
func _update_aim(move: Vector3) -> void:
	var direction: Vector3
	if InputManager.is_gamepad():
		direction = _ground_direction(Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down"))
		if direction.is_zero_approx():
			direction = facing if move.is_zero_approx() else move
	else:
		direction = _cursor_offset()
	if not direction.is_zero_approx():
		aim_direction = direction.normalized()
	# A seta já mostra a mira puxada pela ajuda de mira, para onde o golpe vai de fato.
	var shown := assisted_aim()
	_aim_arrow.rotation.y = atan2(-shown.x, -shown.z)


func _update_animation() -> void:
	if is_dashing() or _control_left > 0.0:
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if is_zero_approx(speed):
		_animator.play(idle_animation)
		_animator.speed_scale = 1.0
	else:
		_animator.play(walk_animation)
		_animator.speed_scale = speed / move_speed()


# Invencível depois de levar golpe, Nate pisca (10-arte-audio).
func _update_blink() -> void:
	var interval := Balance.player.blink_interval
	var hidden := _hurt_invincible_left > 0.0 and interval > 0.0 and fmod(_hurt_invincible_left, 2.0 * interval) < interval
	_model.visible = not hidden


func _die() -> void:
	_dead = true
	_melee.cancel()
	_ranged.cancel()
	flask.cancel()
	_aim_arrow.visible = false
	_model.visible = true
	play_animation(death_animation, 1.0)
	AudioManager.play(&"nate_death", global_position)
	Events.player_died.emit()
	await get_tree().create_timer(Balance.player.death_time, false).timeout
	# O último santuário pode ficar em outra área (depois de subir pelo elevador).
	var area := GameState.respawn_area()
	if area != "" and area != get_tree().current_scene.scene_file_path:
		GameState.change_area(area, &"")
		return
	_respawn()


# Volta ao ponto de retorno com a vida cheia; os inimigos vivos reiniciam (02-core-loop).
func _respawn() -> void:
	global_position = _spawn_position
	velocity = Vector3.ZERO
	facing = _spawn_facing
	_push_left = 0.0
	_control_left = 0.0
	_hurt_invincible_left = 0.0
	_dash_time_left = 0.0
	_dash_cooldown_left = 0.0
	_dead = false
	status.clear()
	spells.reset()
	_boost_left = 0.0
	if has_shield():
		_shield.finish()
	health.reset(max_health())
	flask.refill()
	_aim_arrow.visible = true
	play_animation(idle_animation, 1.0)
	Events.player_respawned.emit()


func _on_inventory_changed() -> void:
	_equip()
	health.set_max(max_health())


func _on_hand_changed() -> void:
	_equip()
	AudioManager.play(&"hand_switch", global_position)


# A vida e a carga novas chegam cheias (05-itens).
func _on_upgrades_changed() -> void:
	health.set_max(max_health(), true)
	flask.refill_new()


## Enquanto Nate bebe, a poção aparece na mão esquerda, no lugar da arma de longe.
func show_flask(on: bool) -> void:
	var holding := GameState.hand_item() is PotionData
	if _flask_model:
		_flask_model.visible = on and not holding
	if _hand_model and _ranged.weapon:
		_hand_model.visible = not on


## O muiraquitã acordando (05-itens): um pulso de luz em volta de Nate, e depois ele fica aceso.
func awaken_amulet() -> void:
	_light.visible = true
	var tween := create_tween()
	tween.tween_method(_pulse_amulet, 0.0, 1.0, awaken_time / 2.0)
	tween.tween_method(_pulse_amulet, 1.0, 0.0, awaken_time / 2.0)
	await tween.finished
	_light.light_energy = ancestral_light_energy
	_show_amulet()


func _pulse_amulet(weight: float) -> void:
	for part in [&"muiraquita", &"muiraquita_chip"]:
		_model.set_part_glow(part, light_color, amulet_glow + weight * awaken_glow)
	_light.light_energy = weight * awaken_light


## A lasca se encaixando (05-itens): o muiraquitã fica inteiro, com o mesmo pulso de luz do despertar.
func fit_seal() -> void:
	_show_amulet()
	AudioManager.play(&"seal", global_position)
	await awaken_amulet()


# O muiraquitã acorda no primeiro pergaminho e passa a brilhar; com o Selo, a lasca aparece no lugar (05-itens).
func _show_amulet() -> void:
	var chip := _model.get_part(&"muiraquita_chip")
	if chip:
		chip.visible = GameState.has_seal()
	for part in [&"muiraquita", &"muiraquita_chip"]:
		_model.set_part_glow(part, light_color, amulet_glow if GameState.has_light() else 0.0)


# A Luz Ancestral acende sozinha nas áreas escuras (05-itens).
func _update_light() -> void:
	var dark := false
	if GameState.has_light():
		for area: DarkArea in get_tree().get_nodes_in_group(&"dark_areas"):
			if area.contains(global_position):
				dark = true
				break
	_light.visible = dark


# Prende o item da mão (a arma de perto na direita; a de longe e a poção na esquerda) e a armadura no corpo, e
# prepara o rastro do golpe com o tamanho da arma.
func _equip() -> void:
	var held := GameState.hand_item()
	# Outro item na mão (os números ou o inventário): o golpe ou o tiro em andamento param; a poção sendo bebida
	# continua.
	if held != _held:
		if _melee.is_busy():
			_melee.cancel()
		if _ranged.is_busy():
			_ranged.cancel()
		_held = held
	_armor = GameState.worn_armor()
	for model in [_hand_model, _armor_model, _flask_model]:
		if is_instance_valid(model):
			model.queue_free()
	_hand_model = null
	_armor_model = null
	_melee.weapon = held as MeleeWeaponData
	_ranged.weapon = held as RangedWeaponData
	if held:
		_hand_model = _attach(held.model, &"hand_r" if held is MeleeWeaponData else &"hand_l")
	if _melee.weapon:
		_swing.mesh = AreaMesh.crescent(_melee.weapon.reach, swing_width, _melee.weapon.angle)
	if _armor:
		_armor_model = _attach(_armor.model, &"body")
	var potion := ItemPlaces.load_item(GameState.FLASK)
	_flask_model = _attach(potion.model, &"hand_l") if potion else null
	show_flask(flask.is_drinking())
	if not _melee.is_busy():
		_swing.visible = false


func _attach(weapon_model: ModelData, hand_name: StringName) -> BlockModel:
	var hand := _model.get_part(hand_name)
	if hand == null:
		return null
	var weapon := BlockModel.new()
	weapon.model = weapon_model
	hand.add_child(weapon)
	return weapon


# Uma direção da tela (x para a direita, y para baixo) vira uma direção no chão, de acordo com a câmera.
# Sempre de tamanho 1: Nate tem uma velocidade só (04-player), e o analógico inclinado de leve anda como o teclado.
func _ground_direction(screen: Vector2) -> Vector3:
	if screen.is_zero_approx():
		return Vector3.ZERO
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3(screen.x, 0.0, screen.y).normalized()
	var right := Vector3(camera.global_basis.x.x, 0.0, camera.global_basis.x.z).normalized()
	var down := Vector3(camera.global_basis.z.x, 0.0, camera.global_basis.z.z).normalized()
	return (right * screen.x + down * screen.y).normalized()


# Do pé de Nate até o ponto do chão embaixo do cursor.
func _cursor_offset() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3.ZERO
	var mouse := get_viewport().get_mouse_position()
	var hit: Variant = Plane(Vector3.UP, global_position.y).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
	if hit == null:
		return Vector3.ZERO
	var offset: Vector3 = hit - global_position
	offset.y = 0.0
	return offset
