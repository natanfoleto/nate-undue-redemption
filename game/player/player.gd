class_name Player
extends CharacterBody3D
## Nate (04-player): anda, olha para onde anda, mira, rola, luta e leva golpes. Os números vêm do Balance.
## O combo, o tiro, as magias e o frasco ficam nos componentes filhos MeleeCombo, RangedShot, SpellCaster e Flask.

@export var idle_animation: AnimationData
@export var walk_animation: AnimationData
@export var roll_animation: AnimationData
@export var hurt_animation: AnimationData
@export var death_animation: AnimationData
## Usa o equipamento do jogo salvo (GameState). A sala de teste desliga e escolhe as armas abaixo.
@export var use_saved_equipment := true
@export var melee_weapon: MeleeWeaponData
@export var ranged_weapon: RangedWeaponData
## Largura do arco do rastro do golpe, em blocos, a partir da borda do alcance.
@export var swing_width := 0.0
## Cor do muiraquitã aceso e da Luz Ancestral (10-arte-audio).
@export var light_color := Color.WHITE
## Força do brilho do muiraquitã aceso.
@export var amulet_glow := 0.0
## O muiraquitã acordando: brilho e luz a mais no auge do pulso, e a duração, em segundos.
@export var awaken_glow := 0.0
@export var awaken_light := 0.0
@export var awaken_time := 0.0

## Direção da mira no chão, de tamanho 1. Os ataques vão nessa direção, puxados pela ajuda de mira.
var aim_direction := Vector3.FORWARD
## Para onde Nate olha, no chão, de tamanho 1.
var facing := Vector3.FORWARD

var _roll_time_left := 0.0
var _roll_cooldown_left := 0.0
var _roll_direction := Vector3.ZERO
var _control_left := 0.0
var _hurt_invincible_left := 0.0
var _push_velocity := Vector3.ZERO
var _push_left := 0.0
var _dead := false
var _spawn_position := Vector3.ZERO
var _spawn_facing := Vector3.FORWARD
var _melee_model: BlockModel
var _ranged_model: BlockModel
var _armor: ArmorData
var _armor_model: BlockModel
var _flask_model: BlockModel
var _cinematic := false
var _boost_share := 0.0
var _boost_left := 0.0
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
	health.reset(max_hearts())
	flask.refill()
	($StatusVisuals as StatusVisuals).fit(_model.height())
	_light.omni_range = Balance.player.light_radius
	_light.light_color = light_color
	_light.visible = false
	_show_amulet()
	GameState.equipment_changed.connect(_on_equipment_changed)
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
		move_and_slide()
		return
	_control_left = maxf(_control_left - delta, 0.0)
	_hurt_invincible_left = maxf(_hurt_invincible_left - delta, 0.0)
	_boost_left = maxf(_boost_left - delta, 0.0)
	var in_control := _control_left == 0.0
	var move := _ground_direction(Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")) if in_control else Vector3.ZERO
	if not is_rolling():
		_roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)
	if in_control:
		_read_actions(move)
	var step := _melee.update(delta)
	_ranged.update(delta)
	spells.update(delta)
	flask.update(delta)
	if is_rolling():
		_update_roll(delta)
	elif _melee.is_busy():
		velocity = step
	elif in_control:
		_walk(move * _speed_share(), delta)
	else:
		velocity = Vector3.ZERO
	if _push_left > 0.0:
		_push_left -= delta
		velocity = _push_velocity
	move_and_slide()
	_update_facing()
	_update_aim(move)
	_update_animation()
	_update_blink()
	_update_light()


func is_rolling() -> bool:
	return _roll_time_left > 0.0


## Corações máximos: os de Nate, os das melhorias e os da armadura (05-itens).
func max_hearts() -> int:
	return Balance.player.max_hearts + GameState.upgrade_count(GameState.HEART_UPGRADE) + (_armor.extra_hearts if _armor else 0)


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


## Escudo de Areia: enquanto a areia gira, o próximo golpe não tira coração.
func raise_shield(area: SpellArea) -> void:
	_shield = area


func has_shield() -> bool:
	return is_instance_valid(_shield)


# Puxando o tiro ou bebendo do frasco, Nate anda mais devagar (04-player).
func _speed_share() -> float:
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
	health.reset(max_hearts())
	flask.refill()
	status.clear()


## Cura do frasco, em corações inteiros.
func heal(hearts: int) -> void:
	health.heal(hearts)


func is_dead() -> bool:
	return _dead


func is_cinematic() -> bool:
	return _cinematic


## Puxando o tiro.
func is_drawing() -> bool:
	return _ranged.is_drawing()


## Rolando ou logo depois de levar golpe, nada fere Nate (03-regras).
func is_invincible() -> bool:
	return is_rolling() or _hurt_invincible_left > 0.0


## A mira puxada para o inimigo mais próximo dentro do cone da ajuda de mira (04-player).
func assisted_aim() -> Vector3:
	var stats := Balance.player
	var best_offset := Vector3.ZERO
	for enemy: Node3D in get_tree().get_nodes_in_group(&"enemies"):
		var offset := enemy.global_position - global_position
		offset.y = 0.0
		if offset.is_zero_approx() or offset.length() > stats.aim_assist_range:
			continue
		# O cone se abre metade para cada lado da mira.
		if rad_to_deg(aim_direction.angle_to(offset)) > stats.aim_assist_angle / 2.0:
			continue
		if best_offset.is_zero_approx() or offset.length() < best_offset.length():
			best_offset = offset
	return aim_direction if best_offset.is_zero_approx() else best_offset.normalized()


## Leva um golpe (03-regras): perde corações inteiros, é empurrado, perde o controle e fica invencível um tempo.
func take_hit(hit: Hit) -> void:
	if _dead or is_invincible():
		return
	if has_shield():
		# O escudo segura o golpe inteiro e se desfaz; Nate ainda é empurrado e pisca.
		_shield.finish()
		_shield = null
	else:
		health.damage(hit.hearts)
		if hit.effect >= 0 and not health.is_dead():
			status.apply(hit.effect, hit.effect_duration, status_duration_share())
	_melee.cancel()
	_ranged.cancel()
	if health.is_dead():
		_die()
		return
	_push(hit.direction, Balance.combat.knockback_distance(hit.knockback))
	_control_left = Balance.player.hit_stun
	_hurt_invincible_left = Balance.player.hit_invincibility
	play_animation(hurt_animation, 1.0)


## Dano do veneno (03-regras): em corações, mas nunca tira o último.
func take_status_damage(hearts: int, _points: int) -> void:
	if _dead:
		return
	health.damage(mini(hearts, health.value - 1))


## De onde sai o tiro: o centro de Nate, na altura da mão que segura a baladeira, para o projétil voar
## na linha da mira e não ao lado dela.
func shot_origin() -> Vector3:
	var hand := _model.get_part(&"hand_l")
	var height := hand.global_position.y if hand else global_position.y + 1.0
	return Vector3(global_position.x, height, global_position.z)


func play_animation(animation: AnimationData, speed: float) -> void:
	_animator.restart(animation)
	_animator.speed_scale = speed


func play_overlay(animation: AnimationData, speed: float) -> void:
	_animator.play_overlay(animation, speed)


func stop_overlay() -> void:
	_animator.stop_overlay()


## Rastro do golpe (10-arte-audio): um arco branco curto na direção do golpe, durante o tempo ativo.
func show_swing(on: bool) -> void:
	_swing.visible = on
	var direction := _melee.direction()
	_swing.rotation.y = atan2(-direction.x, -direction.z)


func show_ranged_weapon(on: bool) -> void:
	if _ranged_model:
		_ranged_model.visible = on


## Brilho na arma quando o tiro chega à força total (10-arte-audio).
func set_ranged_glow(on: bool) -> void:
	if _ranged_model:
		_ranged_model.set_glow(1.0 if on else 0.0)


func _read_actions(move: Vector3) -> void:
	# A esquiva cancela a recuperação dos golpes e o tiro (04-player).
	var can_dodge := not is_rolling() and (not _melee.is_busy() or _melee.in_recovery())
	if flask.is_drinking():
		return
	if Input.is_action_just_pressed(&"dodge") and can_dodge and is_zero_approx(_roll_cooldown_left):
		_melee.cancel()
		_ranged.cancel()
		_start_roll(move)
		return
	if is_rolling():
		return
	if Input.is_action_just_pressed(&"melee_attack") and not _ranged.is_busy():
		_melee.press()
	if Input.is_action_just_pressed(&"ranged_attack") and not _melee.is_busy():
		_ranged.press()
	# Pelo estado do botão, e não pelo quadro em que foi solto: com o jogo pausado, esse quadro não roda.
	if _ranged.is_drawing() and not Input.is_action_pressed(&"ranged_attack"):
		_ranged.release()
	var hands_free := not _melee.is_busy() and not _ranged.is_busy()
	if hands_free and GameState.learned_elements().size() > 0:
		if Input.is_action_just_pressed(&"spell_1"):
			spells.press(0)
		if Input.is_action_just_pressed(&"spell_2"):
			spells.press(1)
	if Input.is_action_just_pressed(&"flask") and hands_free:
		flask.press()
		return
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
	velocity = velocity.move_toward(move * speed, rate * delta)


func _start_roll(move: Vector3) -> void:
	var stats := Balance.player
	_roll_direction = facing if move.is_zero_approx() else move
	_roll_time_left = stats.roll_duration
	play_animation(roll_animation, roll_animation.length / stats.roll_duration)


# Anda exatamente a distância do rolamento: o último passo da física só cobre o tempo que faltava.
func _update_roll(delta: float) -> void:
	var stats := Balance.player
	var step := minf(delta, _roll_time_left)
	velocity = _roll_direction * (stats.roll_distance / stats.roll_duration) * (step / delta)
	_roll_time_left -= step
	if _roll_time_left <= 0.0:
		_roll_time_left = 0.0
		_roll_cooldown_left = _armor.roll_cooldown if _armor and _armor.roll_cooldown > 0.0 else stats.roll_cooldown


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
	if is_rolling() or _melee.is_busy() or _control_left > 0.0:
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
	_roll_time_left = 0.0
	_roll_cooldown_left = 0.0
	_dead = false
	status.clear()
	spells.reset()
	_boost_left = 0.0
	if has_shield():
		_shield.finish()
	health.reset(max_hearts())
	flask.refill()
	_aim_arrow.visible = true
	play_animation(idle_animation, 1.0)
	Events.player_respawned.emit()


func _on_equipment_changed() -> void:
	_equip()
	health.set_max(max_hearts())


# O coração e a carga novos chegam cheios (05-itens).
func _on_upgrades_changed() -> void:
	health.set_max(max_hearts(), true)
	flask.refill_new()


## Mostra a moringa na mão enquanto Nate bebe.
func show_flask(on: bool) -> void:
	if _flask_model:
		_flask_model.visible = on
	if on and _ranged_model:
		_ranged_model.visible = false


## O muiraquitã acordando (05-itens): um pulso de luz em volta de Nate, e depois ele fica aceso.
func awaken_amulet() -> void:
	_light.visible = true
	var tween := create_tween()
	tween.tween_method(_pulse_amulet, 0.0, 1.0, awaken_time / 2.0)
	tween.tween_method(_pulse_amulet, 1.0, 0.0, awaken_time / 2.0)
	await tween.finished
	_light.light_energy = 1.0
	_show_amulet()


func _pulse_amulet(weight: float) -> void:
	for part in [&"muiraquita", &"muiraquita_chip"]:
		_model.set_part_glow(part, light_color, amulet_glow + weight * awaken_glow)
	_light.light_energy = weight * awaken_light


## A lasca se encaixando (05-itens): o muiraquitã fica inteiro, com o mesmo pulso de luz do despertar.
func fit_seal() -> void:
	_show_amulet()
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


# Prende as armas nas mãos e a armadura no corpo, e prepara o rastro do golpe com o tamanho da arma.
func _equip() -> void:
	var melee: MeleeWeaponData = melee_weapon
	var ranged: RangedWeaponData = ranged_weapon
	_armor = null
	if use_saved_equipment:
		melee = GameState.equipped(GameState.MELEE) as MeleeWeaponData
		ranged = GameState.equipped(GameState.RANGED) as RangedWeaponData
		_armor = GameState.equipped(GameState.ARMOR) as ArmorData
	for model in [_melee_model, _ranged_model, _armor_model, _flask_model]:
		if is_instance_valid(model):
			model.queue_free()
	_melee.weapon = melee
	_ranged.weapon = ranged
	if melee:
		_melee_model = _attach(melee.model, &"hand_r")
		_swing.mesh = AreaMesh.arc(melee.reach - swing_width, melee.reach, melee.angle)
	if ranged:
		_ranged_model = _attach(ranged.model, &"hand_l")
		show_ranged_weapon(false)
	if _armor:
		_armor_model = _attach(_armor.model, &"body")
	_flask_model = _attach(flask.model, &"hand_l")
	show_flask(false)
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
