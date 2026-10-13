class_name SpellArea
extends Node3D
## Área de magia que fica um tempo (05-itens): no chão (a nuvem do Vapor, a lama do Lamaçal) ou em volta de Nate,
## seguindo-o (a Tempestade de Fogo, o Escudo de Areia). Enquanto dura, renova o efeito em quem está dentro e, se a
## magia empurra, empurra quem entra.

var _spell: SpellData
var _left := 0.0
var _faction := Hurtbox.Faction.ENEMY
var _build_hit: Callable
var _follow: Node3D
var _inside: Array[Node3D] = []


## Começa a área. [param build_hit] monta o golpe de quem entra (vazio quando a magia só tem efeito);
## [param follow] é quem ela segue.
func start(spell: SpellData, faction: Hurtbox.Faction, build_hit := Callable(), follow: Node3D = null) -> void:
	_spell = spell
	_left = spell.lasting
	_faction = faction
	_build_hit = build_hit
	_follow = follow


## Acaba antes da hora (o Escudo de Areia que segurou o golpe).
func finish() -> void:
	_left = 0.0


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0 or (_follow != null and not is_instance_valid(_follow)):
		queue_free()
		return
	if _follow:
		global_position = _follow.global_position
	var duration := _effect_duration()
	var now_inside: Array[Node3D] = []
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(_faction)):
		if not HitShape.overlaps(_spell.attack, global_position, Vector3.FORWARD, hurtbox.global_position, hurtbox.radius):
			continue
		if absf(hurtbox.global_position.y - global_position.y) > Balance.combat.height_reach:
			continue
		var receiver := hurtbox.receiver
		now_inside.append(receiver)
		# Quem acabou de entrar leva o golpe uma vez (o recuo da Tempestade de Fogo).
		if _build_hit.is_valid() and receiver not in _inside:
			receiver.call(&"take_hit", _build_hit.call(receiver))
		if _spell.effect >= 0:
			var status := receiver.get_node_or_null(^"StatusEffects") as StatusEffects
			if status:
				status.apply(_spell.effect, duration)
	_inside = now_inside


# A queimadura dura o tempo das regras de status; a lentidão dura enquanto está dentro e mais um pouco.
func _effect_duration() -> float:
	match _spell.effect:
		StatusEffects.Effect.BURN:
			return Balance.status.burn_duration
		StatusEffects.Effect.SLOW:
			return Balance.status.slow_linger
		_:
			return _spell.effect_duration
