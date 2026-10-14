extends GdUnitTestSuite
## O resumo do fim (09-interface): o tempo de jogo escrito e as contas do que existe no mapa (08-mapa: 13 melhorias,
## 4 pergaminhos e 5 peças de equipamento, além da espada inicial).

const AREAS: Array[String] = ["mine", "forest", "ruins", "prison"]


func test_play_time_is_written_in_hours_minutes_and_seconds() -> void:
	assert_str(SummaryScreen.time_text(0.0)).is_equal("0:00")
	assert_str(SummaryScreen.time_text(65.4)).is_equal("1:05")
	assert_str(SummaryScreen.time_text(3725.0)).is_equal("1:02:05")


func test_totals_match_the_map() -> void:
	var data: SummaryData = load("res://data/ui/summary.tres")
	var upgrades := {}
	var scrolls := 0
	var pieces: Array[String] = []
	var upgrade_id := RegEx.create_from_string("save_id = &\"((heart|charge)_[a-z_0-9]+)\"")
	var item_id := RegEx.create_from_string("item_id = &\"([a-z_]+)\"")
	for area in AREAS:
		var text := FileAccess.get_file_as_string("res://world/areas/%s.tscn" % area)
		for found in upgrade_id.search_all(text):
			upgrades[found.get_string(1)] = true
		scrolls += text.count("element_id = &\"")
		for found in item_id.search_all(text):
			pieces.append(found.get_string(1))
	assert_int(upgrades.size()).is_equal(data.upgrades_total)
	assert_int(scrolls).is_equal(data.scrolls_total)
	# Cada peça de equipamento está no mapa uma vez, e toda arma ou armadura do jogo, menos a espada inicial, conta.
	for id in data.equipment:
		assert_int(pieces.count(String(id))).is_equal(1)
	var equipment := 0
	for file in DirAccess.get_files_at("res://data/items/"):
		var item := load("res://data/items/" + file.trim_suffix(".remap"))
		var piece := item is MeleeWeaponData or item is RangedWeaponData or item is ArmorData
		if piece and file.get_basename() != "sword":
			equipment += 1
	assert_int(equipment).is_equal(data.equipment.size())
