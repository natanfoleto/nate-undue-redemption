class_name SpellArea
extends Node3D
## Área de magia que fica no chão por um tempo (05-itens): a nuvem do Vapor, a lama do Lamaçal. Enquanto
## dura, renova o efeito em quem está dentro.

var _spell: SpellData
var _left := 0.0
var _faction := Hurtbox.Faction.ENEMY


func start(spell: SpellData, faction: Hurtbox.Faction) -> void:
	_spell = spell
	_left = spell.lasting
	_faction = faction


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		queue_free()
		return
	if _spell.effect < 0:
		return
	var duration := _effect_duration()
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(_faction)):
		if HitShape.overlaps(_spell.attack, global_position, Vector3.FORWARD, hurtbox.global_position, hurtbox.radius):
			var status := hurtbox.receiver.get_node_or_null(^"StatusEffects") as StatusEffects
			if status:
				status.apply(_spell.effect, duration)


# A queimadura dura o tempo das regras de status; a lentidão dura enquanto está dentro e mais um pouco.
func _effect_duration() -> float:
	match _spell.effect:
		StatusEffects.Effect.BURN:
			return Balance.status.burn_duration
		StatusEffects.Effect.SLOW:
			return Balance.status.slow_linger
		_:
			return _spell.effect_duration
