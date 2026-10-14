extends GdUnitTestSuite
## A vida da Boiúna (07-chefes/boiuna, 11-balanceamento): na fase 1, 4 partes de 180; cada parte cai inteira e a
## deixa atordoada, e a seguinte só cai depois que um pilar acende para cada parte derrubada. Na fase 2, uma barra só,
## e o fim dela vence a luta. Os efeitos de status não pegam nela.

var _boiuna: Boiuna


func before_test() -> void:
	_boiuna = auto_free((load("res://boss/boiuna.tscn") as PackedScene).instantiate())
	add_child(_boiuna)
	_boiuna.wake(false)
	_boiuna.state = Boiuna.State.IDLE


func _hit(points: int, effect := -1) -> void:
	var hit := Hit.new()
	hit.points = points
	hit.effect = effect
	hit.effect_duration = 2.0
	_boiuna.take_hit(hit)


func test_phase_one_has_four_parts_of_180() -> void:
	assert_int(_boiuna.health.max_value).is_equal(720)
	assert_int(_boiuna.parts_broken()).is_equal(0)


func test_a_part_falls_whole_and_stuns() -> void:
	_hit(170)
	assert_int(_boiuna.state).is_equal(Boiuna.State.IDLE)
	# O golpe que passa do fim da parte para nele: a sobra não entra na parte seguinte.
	_hit(50)
	assert_int(_boiuna.health.value).is_equal(540)
	assert_int(_boiuna.parts_broken()).is_equal(1)
	assert_int(_boiuna.state).is_equal(Boiuna.State.STUNNED)
	assert_bool(_boiuna.status.has(StatusEffects.Effect.STUN)).is_true()


func test_the_next_part_waits_for_a_pillar() -> void:
	_hit(180)
	_boiuna.state = Boiuna.State.IDLE
	assert_bool(_boiuna.is_locked()).is_true()
	_hit(50)
	assert_int(_boiuna.health.value).is_equal(540)
	_boiuna.pillars_active = 1
	assert_bool(_boiuna.is_locked()).is_false()
	_hit(50)
	assert_int(_boiuna.health.value).is_equal(490)


func test_a_pillar_lit_before_the_stun_keeps_the_next_part_open() -> void:
	_boiuna.pillars_active = 1
	_hit(180)
	_boiuna.state = Boiuna.State.IDLE
	_hit(30)
	assert_int(_boiuna.health.value).is_equal(510)


func test_status_effects_do_not_stick() -> void:
	_hit(10, StatusEffects.Effect.BURN)
	assert_int(_boiuna.health.value).is_equal(710)
	assert_bool(_boiuna.status.has(StatusEffects.Effect.BURN)).is_false()


func test_asleep_she_takes_no_hit() -> void:
	_boiuna.sleep()
	_hit(50)
	assert_int(_boiuna.health.value).is_equal(720)


func test_phase_two_has_one_bar_and_its_end_wins_the_fight() -> void:
	_boiuna.start_phase_2()
	_boiuna.state = Boiuna.State.REST
	assert_int(_boiuna.health.max_value).is_equal(400)
	var defeated := [false]
	_boiuna.defeated.connect(func() -> void: defeated[0] = true)
	_hit(399)
	assert_bool(defeated[0]).is_false()
	_hit(5)
	assert_bool(defeated[0]).is_true()
