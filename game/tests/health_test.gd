extends GdUnitTestSuite
## Vida (03-regras, 05-itens): os corações da armadura chegam vazios e a vida é cortada ao tirá-la; os das
## melhorias chegam cheios; o frasco cura até o máximo.


func test_armor_hearts_arrive_empty() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(5)
	health.damage(3)
	health.set_max(6)
	assert_int(health.value).is_equal(2)
	assert_int(health.max_value).is_equal(6)


func test_removing_armor_cuts_the_life() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(6)
	health.set_max(5)
	assert_int(health.value).is_equal(5)
	health.damage(2)
	health.set_max(4)
	assert_int(health.value).is_equal(3)


func test_upgrade_heart_arrives_full() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(5)
	health.damage(3)
	health.set_max(6, true)
	assert_int(health.value).is_equal(3)
	assert_int(health.max_value).is_equal(6)


func test_heal_stops_at_the_maximum() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(5)
	health.damage(3)
	health.heal(2)
	assert_int(health.value).is_equal(4)
	health.heal(2)
	assert_int(health.value).is_equal(5)


func test_dead_is_not_healed() -> void:
	var health: Health = auto_free(Health.new())
	health.reset(5)
	health.damage(5)
	health.heal(2)
	assert_int(health.value).is_equal(0)


func test_combo_key_ignores_the_order() -> void:
	assert_str(ComboTable.key(&"water", &"fire")).is_equal("fire+water")
	assert_str(ComboTable.key(&"fire", &"water")).is_equal("fire+water")
