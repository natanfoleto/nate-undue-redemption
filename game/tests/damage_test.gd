extends GdUnitTestSuite
## Fórmula do dano que Nate causa (03-regras).


func test_example_from_the_rules() -> void:
	# Espada 10, +20% de bônus, variação 1,05 e crítico: 10 × 1,2 × 1,05 × 2 = 25,2 → 25.
	assert_int(Damage.points(10.0, 0.2, 1.05, true, 2.0)).is_equal(25)


func test_without_bonus_variation_or_critical_keeps_the_base() -> void:
	assert_int(Damage.points(10.0, 0.0, 1.0, false, 2.0)).is_equal(10)


func test_bonuses_add_before_multiplying() -> void:
	# +20% e +15% somam 35%: 10 × 1,35 = 13,5, que arredonda para 14.
	assert_int(Damage.points(10.0, 0.2 + 0.15, 1.0, false, 2.0)).is_equal(14)


func test_variation_limits() -> void:
	assert_int(Damage.points(10.0, 0.0, 0.9, false, 2.0)).is_equal(9)
	assert_int(Damage.points(10.0, 0.0, 1.1, false, 2.0)).is_equal(11)


func test_third_combo_hit_with_critical() -> void:
	assert_int(Damage.points(15.0, 0.0, 1.0, true, 2.0)).is_equal(30)


func test_roll_stays_inside_the_variation() -> void:
	var rules := _rules()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 200:
		var hit := Damage.roll(10.0, 0.0, 0.0, rules, rng)
		assert_bool(hit.critical).is_false()
		assert_int(hit.points).is_between(9, 11)


func test_roll_with_certain_critical_doubles() -> void:
	var rules := _rules()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 200:
		var hit := Damage.roll(10.0, 0.0, 1.0, rules, rng)
		assert_bool(hit.critical).is_true()
		assert_int(hit.points).is_between(18, 22)


# As magias que só empurram têm dano 0: nunca saem como crítico, que mostraria um "0" amarelo.
func test_roll_without_damage_is_never_critical() -> void:
	var rules := _rules()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 50:
		var hit := Damage.roll(0.0, 0.0, 1.0, rules, rng)
		assert_bool(hit.critical).is_false()
		assert_int(hit.points).is_equal(0)


func _rules() -> CombatRules:
	var rules := CombatRules.new()
	rules.damage_variation_min = 0.9
	rules.damage_variation_max = 1.1
	rules.critical_multiplier = 2.0
	return rules
