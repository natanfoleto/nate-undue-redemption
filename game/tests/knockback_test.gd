extends GdUnitTestSuite
## Recuo e peso (03-regras): leve, qualquer recuo empurra e interrompe; pesado, só o longo; chefe, nenhum.


func test_light_is_pushed_by_short_and_long() -> void:
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.LIGHT, AttackData.Knockback.NONE)).is_false()
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.LIGHT, AttackData.Knockback.SHORT)).is_true()
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.LIGHT, AttackData.Knockback.LONG)).is_true()


func test_heavy_is_pushed_only_by_long() -> void:
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.HEAVY, AttackData.Knockback.SHORT)).is_false()
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.HEAVY, AttackData.Knockback.LONG)).is_true()


func test_boss_is_never_pushed() -> void:
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.BOSS, AttackData.Knockback.SHORT)).is_false()
	assert_bool(CombatRules.knockback_affects(CombatRules.Weight.BOSS, AttackData.Knockback.LONG)).is_false()


func test_distances_come_from_the_rules() -> void:
	var rules := CombatRules.new()
	rules.short_knockback = 1.0
	rules.long_knockback = 3.0
	assert_float(rules.knockback_distance(AttackData.Knockback.NONE)).is_equal(0.0)
	assert_float(rules.knockback_distance(AttackData.Knockback.SHORT)).is_equal(1.0)
	assert_float(rules.knockback_distance(AttackData.Knockback.LONG)).is_equal(3.0)
