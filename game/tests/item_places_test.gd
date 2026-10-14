extends GdUnitTestSuite
## Lugares dos itens (05-itens): armas e a poção entram na barra, a armadura veste se Nate estiver sem nenhuma, o
## que não cabe vai para a mochila; trocar de lugar só vale quando cada item cabe no lugar do outro.

var _data: Dictionary


func before_test() -> void:
	_data = {"hotbar": ["sword", "", "", "", ""], "bag": [], "armor": ""}


func test_weapons_and_the_potion_go_to_the_hotbar() -> void:
	ItemPlaces.place(_data, "slingshot")
	ItemPlaces.place(_data, "flask")
	assert_array(_data["hotbar"]).is_equal(["sword", "slingshot", "flask", "", ""])


func test_first_armor_is_worn_and_the_next_goes_to_the_bag() -> void:
	ItemPlaces.place(_data, "fiber_cloak")
	ItemPlaces.place(_data, "cuirass")
	assert_str(String(_data["armor"])).is_equal("fiber_cloak")
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.BAG, 0)).is_equal("cuirass")


func test_full_hotbar_sends_weapons_to_the_bag() -> void:
	_data["hotbar"] = ["sword", "slingshot", "spear", "flask", "seal"]
	ItemPlaces.place(_data, "bow")
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.BAG, 0)).is_equal("bow")


func test_an_item_is_kept_in_one_place_only() -> void:
	ItemPlaces.place(_data, "sword")
	assert_array(_data["hotbar"]).is_equal(["sword", "", "", "", ""])
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.BAG, 0)).is_empty()


func test_armor_never_goes_to_the_hotbar() -> void:
	ItemPlaces.place(_data, "cuirass")
	assert_bool(ItemPlaces.can_move(_data, ItemPlaces.ARMOR, 0, ItemPlaces.HOTBAR, 1)).is_false()
	# Nem trocando com a arma de um espaço da barra.
	assert_bool(ItemPlaces.can_move(_data, ItemPlaces.HOTBAR, 0, ItemPlaces.ARMOR, 0)).is_false()


func test_moving_swaps_the_two_places() -> void:
	ItemPlaces.place(_data, "slingshot")
	assert_bool(ItemPlaces.move(_data, ItemPlaces.HOTBAR, 0, ItemPlaces.HOTBAR, 1)).is_true()
	assert_array(_data["hotbar"]).is_equal(["slingshot", "sword", "", "", ""])
	assert_bool(ItemPlaces.move(_data, ItemPlaces.HOTBAR, 0, ItemPlaces.BAG, 3)).is_true()
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.HOTBAR, 0)).is_empty()
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.BAG, 3)).is_equal("slingshot")


func test_taking_the_armor_off_leaves_nate_without_one() -> void:
	ItemPlaces.place(_data, "cuirass")
	assert_bool(ItemPlaces.move(_data, ItemPlaces.ARMOR, 0, ItemPlaces.BAG, 0)).is_true()
	assert_str(String(_data["armor"])).is_empty()
	assert_str(ItemPlaces.id_at(_data, ItemPlaces.BAG, 0)).is_equal("cuirass")


func test_an_empty_place_moves_nothing() -> void:
	assert_bool(ItemPlaces.can_move(_data, ItemPlaces.HOTBAR, 2, ItemPlaces.BAG, 0)).is_false()
