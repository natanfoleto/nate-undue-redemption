extends GdUnitTestSuite
## Vida (03-regras, 05-itens), em pontos: a vida a mais da armadura chega vazia e a vida é cortada ao tirá-la; a
## das melhorias chega cheia; a poção cura até o máximo.


func test_armor_health_arrives_empty() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(100)
	health.damage(60)
	health.set_max(120)
	assert_int(health.value).is_equal(40)
	assert_int(health.max_value).is_equal(120)


func test_removing_armor_cuts_the_life() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(120)
	health.set_max(100)
	assert_int(health.value).is_equal(100)
	health.damage(40)
	health.set_max(40)
	assert_int(health.value).is_equal(40)


func test_upgrade_health_arrives_full() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(100)
	health.damage(60)
	health.set_max(120, true)
	assert_int(health.value).is_equal(60)
	assert_int(health.max_value).is_equal(120)


func test_heal_stops_at_the_maximum() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(100)
	health.damage(60)
	health.heal(40)
	assert_int(health.value).is_equal(80)
	health.heal(40)
	assert_int(health.value).is_equal(100)


func test_dead_is_not_healed() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(100)
	health.damage(100)
	health.heal(40)
	assert_int(health.value).is_equal(0)


func test_combo_key_ignores_the_order() -> void:
	assert_str(ComboTable.key(&"water", &"fire")).is_equal("fire+water")
	assert_str(ComboTable.key(&"fire", &"water")).is_equal("fire+water")
