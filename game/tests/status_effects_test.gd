extends GdUnitTestSuite
## Efeitos de status (03-regras, 11-balanceamento): o mesmo efeito não acumula, efeitos diferentes valem juntos,
## o lento anda à metade, a queimadura tira 4 pontos a cada 0,5 s por 2 s, o veneno tira 1 coração depois de
## 2 s e, com a Água equipada, acaba antes de agir.

const FRAME := 1.0 / 60.0


class Receiver:
	extends Node
	var hearts := 0
	var points := 0

	func take_status_damage(lost_hearts: int, lost_points: int) -> void:
		hearts += lost_hearts
		points += lost_points


var _receiver: Receiver
var _status: StatusEffects


func before_test() -> void:
	_receiver = auto_free(Receiver.new())
	_status = StatusEffects.new()
	_receiver.add_child(_status)


func test_slow_halves_the_speed() -> void:
	assert_float(_status.speed_share()).is_equal(1.0)
	_status.apply(StatusEffects.Effect.SLOW, 2.0)
	assert_float(_status.speed_share()).is_equal(0.5)
	_run(2.1)
	assert_bool(_status.has(StatusEffects.Effect.SLOW)).is_false()
	assert_float(_status.speed_share()).is_equal(1.0)


func test_same_effect_renews_instead_of_stacking() -> void:
	_status.apply(StatusEffects.Effect.SLOW, 2.0)
	_run(1.5)
	_status.apply(StatusEffects.Effect.SLOW, 2.0)
	_run(1.5)
	assert_bool(_status.has(StatusEffects.Effect.SLOW)).is_true()
	assert_int(_status.active().size()).is_equal(1)


func test_different_effects_stay_together() -> void:
	_status.apply(StatusEffects.Effect.SLOW, 2.0)
	_status.apply(StatusEffects.Effect.STUN, 2.0)
	assert_int(_status.active().size()).is_equal(2)


func test_burn_takes_16_points_in_2_seconds() -> void:
	_status.apply(StatusEffects.Effect.BURN, 2.0)
	_run(3.0)
	assert_int(_receiver.points).is_equal(16)
	assert_int(_receiver.hearts).is_equal(0)
	assert_bool(_status.has(StatusEffects.Effect.BURN)).is_false()


func test_burn_renewed_keeps_its_rhythm() -> void:
	_status.apply(StatusEffects.Effect.BURN, 2.0)
	_run(1.0)
	# Renovar no meio não reinicia o tique: são 2 tiques no primeiro segundo e mais 4 nos 2 s da renovação.
	_status.apply(StatusEffects.Effect.BURN, 2.0)
	_run(3.0)
	assert_int(_receiver.points).is_equal(24)


func test_poison_takes_one_heart_after_two_seconds() -> void:
	_status.apply(StatusEffects.Effect.POISON, 2.0)
	_run(1.9)
	assert_int(_receiver.hearts).is_equal(0)
	_run(0.2)
	assert_int(_receiver.hearts).is_equal(1)
	assert_bool(_status.has(StatusEffects.Effect.POISON)).is_false()


func test_water_ends_the_poison_before_it_acts() -> void:
	_status.apply(StatusEffects.Effect.POISON, 2.0, 0.5)
	_run(3.0)
	assert_int(_receiver.hearts).is_equal(0)
	assert_bool(_status.has(StatusEffects.Effect.POISON)).is_false()


func test_water_halves_the_slow() -> void:
	_status.apply(StatusEffects.Effect.SLOW, 2.0, 0.5)
	_run(0.9)
	assert_bool(_status.has(StatusEffects.Effect.SLOW)).is_true()
	_run(0.2)
	assert_bool(_status.has(StatusEffects.Effect.SLOW)).is_false()


func test_immune_takes_nothing() -> void:
	_status.immune = true
	assert_bool(_status.apply(StatusEffects.Effect.BURN, 2.0)).is_false()
	assert_bool(_status.has(StatusEffects.Effect.BURN)).is_false()


func test_stun_proof_is_never_stunned() -> void:
	_status.stun_proof = true
	assert_bool(_status.apply(StatusEffects.Effect.STUN, 2.0)).is_false()
	assert_bool(_status.apply(StatusEffects.Effect.SLOW, 2.0)).is_true()


func test_clear_removes_everything() -> void:
	_status.apply(StatusEffects.Effect.SLOW, 2.0)
	_status.apply(StatusEffects.Effect.BURN, 2.0)
	_status.clear()
	assert_array(_status.active()).is_empty()
	_run(1.0)
	assert_int(_receiver.points).is_equal(0)


# Avança o tempo em quadros de 1/60 s, como a física do jogo.
func _run(seconds: float) -> void:
	for i in roundi(seconds / FRAME):
		_status._physics_process(FRAME)
