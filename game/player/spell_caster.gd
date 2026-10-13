class_name SpellCaster
extends Node
## Magias (04-player, 05-itens): Q e E lançam a magia de cada elemento equipado; os dois juntos lançam a
## combinação, que só sai com as duas prontas e põe as duas para recarregar. Cada recarga conta mesmo com o
## elemento fora do espaço. Todas usam a mesma pose de Nate. O pai é o Player.

const PROJECTILE := preload("res://combat/projectile.tscn")

## A pose de usar magia, a mesma para as 10 (04-player).
@export var cast_animation: AnimationData
@export var combos: ComboTable
## Tempo para esperar o outro botão e lançar a combinação, em segundos.
@export var combo_window := 0.0
## Brilho do projétil da magia, na cor dela.
@export var projectile_glow := 0.0
## Aparência dos efeitos das magias.
@export var effect_look: EffectLook

var _cooldowns: Dictionary[StringName, float] = {}
var _pending := -1
var _pending_left := 0.0
var _pose_left := 0.0
var _rng := RandomNumberGenerator.new()

@onready var _player: Player = get_parent()


## Aperto de Q (0) ou E (1). Se o outro foi apertado há pouco, sai a combinação.
func press(slot: int) -> void:
	if _pending == 1 - slot and _pending_left > 0.0:
		_pending = -1
		_cast_combo()
		return
	_pending = slot
	_pending_left = combo_window


func update(delta: float) -> void:
	for id: StringName in _cooldowns.keys():
		_cooldowns[id] = maxf(_cooldowns[id] - delta, 0.0)
	if _pending >= 0:
		_pending_left -= delta
		if _pending_left <= 0.0:
			var slot := _pending
			_pending = -1
			_cast_single(slot)
	if _pose_left > 0.0:
		_pose_left -= delta
		if _pose_left <= 0.0 and not _player.flask.is_drinking() and not _player.is_drawing():
			_player.stop_overlay()


func is_ready(element_id: StringName) -> bool:
	return _cooldowns.get(element_id, 0.0) == 0.0


## Quanto da recarga ainda falta, de 0 (pronta) a 1.
func cooldown_share(element_id: StringName) -> float:
	var element: ElementData = load(GameState.ELEMENTS_FOLDER + element_id + ".tres")
	if element == null or element.spell.cooldown <= 0.0:
		return 0.0
	return _cooldowns.get(element_id, 0.0) / element.spell.cooldown


## A combinação dos dois elementos equipados, se existe e se as duas magias estão prontas.
func combo_ready() -> bool:
	var first := GameState.equipped_element_id(0)
	var second := GameState.equipped_element_id(1)
	if first == &"" or second == &"":
		return false
	return combos.find(first, second) != null and is_ready(first) and is_ready(second)


## Zera as recargas (Nate voltando depois de morrer).
func reset() -> void:
	_cooldowns.clear()
	_pending = -1


func _cast_single(slot: int) -> void:
	var element := GameState.equipped_element(slot)
	var id := GameState.equipped_element_id(slot)
	if element == null or not is_ready(id):
		return
	_cooldowns[id] = element.spell.cooldown
	_launch(element.spell)


func _cast_combo() -> void:
	if not combo_ready():
		return
	for slot in 2:
		_cooldowns[GameState.equipped_element_id(slot)] = GameState.equipped_element(slot).spell.cooldown
	_launch(combos.find(GameState.equipped_element_id(0), GameState.equipped_element_id(1)))


func _launch(spell: SpellData) -> void:
	_player.play_overlay(cast_animation, 1.0)
	_pose_left = cast_animation.length
	var direction := _player.assisted_aim()
	var origin := _player.global_position
	var world := _player.get_parent()
	match spell.delivery:
		SpellData.Delivery.PROJECTILE:
			var projectile := PROJECTILE.instantiate() as Projectile
			world.add_child(projectile)
			projectile.global_position = _player.shot_origin()
			var model := projectile.get_node(^"BlockModel") as BlockModel
			model.model = spell.projectile_model
			model.set_glow(projectile_glow, spell.color)
			projectile.launch(spell.attack, direction, Hurtbox.Faction.ENEMY, Callable(), _explode.bind(spell))
		SpellData.Delivery.INSTANT:
			var hit_list: Array[Node3D] = []
			Strike.hit_area(spell.attack, _player, origin, direction, Hurtbox.Faction.ENEMY, hit_list, _build_hit.bind(spell, origin))
			SpellEffects.wave(world, origin, direction, spell.attack.reach, spell.attack.width, spell.color, cast_animation.length, effect_look)
		SpellData.Delivery.LASTING:
			var area := SpellArea.new()
			world.add_child(area)
			area.global_position = origin + direction * spell.offset
			area.start(spell, Hurtbox.Faction.ENEMY)
			SpellEffects.cloud(area, spell.color, spell.attack.reach, effect_look)


func _explode(where: Vector3, spell: SpellData) -> void:
	var hit_list: Array[Node3D] = []
	var center := Vector3(where.x, _player.global_position.y, where.z)
	Strike.hit_area(spell.explosion, _player, center, Vector3.FORWARD, Hurtbox.Faction.ENEMY, hit_list, _build_hit.bind(spell, center))
	SpellEffects.burst(_player.get_parent(), center, spell.color, spell.explosion.reach, effect_look)


# O dano das magias segue a mesma fórmula dos golpes de Nate (03-regras); o empurrão sai do centro da magia.
func _build_hit(receiver: Node3D, spell: SpellData, center: Vector3) -> Hit:
	var attack := spell.explosion if spell.explosion else spell.attack
	var hit := Damage.roll(attack.damage_points, 0.0, Balance.player.critical_chance, Balance.combat, _rng)
	hit.attacker = _player
	hit.knockback = attack.knockback
	var away := receiver.global_position - center
	away.y = 0.0
	hit.direction = away.normalized() if not away.is_zero_approx() else _player.facing
	if spell.effect >= 0:
		hit.effect = spell.effect
		hit.effect_duration = Balance.status.burn_duration if spell.effect == StatusEffects.Effect.BURN else spell.effect_duration
	return hit
