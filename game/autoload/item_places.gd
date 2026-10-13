class_name ItemPlaces
## Onde ficam os itens no jogo salvo (05-itens, 12-tecnico): a barra fixa ("hotbar", 5 espaços, só os itens de mão:
## armas e a poção), a mochila ("bag", 15 espaços, tudo) e a armadura vestida ("armor"). Funções puras sobre os
## dados do jogo salvo; o GameState as usa com os dados abertos, e o SaveSystem, ao converter um jogo antigo.

const HOTBAR := "hotbar"
const BAG := "bag"
const ARMOR := "armor"
const HOTBAR_SIZE := 5
const BAG_SIZE := 15
## Pasta dos itens: o identificador de um item é o nome do arquivo.
const ITEMS_FOLDER := "res://data/items/"


## O item de um identificador, ou nulo se ele não existe.
static func load_item(id: String) -> ItemData:
	var path := ITEMS_FOLDER + id + ".tres"
	return load(path) as ItemData if id != "" and ResourceLoader.exists(path) else null


## Armas e a poção: o que Nate segura e usa com o botão de usar.
static func is_hand_item(item: ItemData) -> bool:
	return item is MeleeWeaponData or item is RangedWeaponData or item is PotionData


## Se o item pode ficar no lugar: na barra, só os itens de mão; no corpo, só a armadura; na mochila, todos.
static func fits(item: ItemData, place: String) -> bool:
	if item == null:
		return true
	if place == HOTBAR:
		return is_hand_item(item)
	if place == ARMOR:
		return item is ArmorData
	return true


## A lista de um lugar, sempre com todos os espaços (vazio é "").
static func list(data: Dictionary, place: String) -> Array:
	var spots: Array = data.get_or_add(place, [])
	var size := HOTBAR_SIZE if place == HOTBAR else BAG_SIZE
	while spots.size() < size:
		spots.append("")
	return spots


static func id_at(data: Dictionary, place: String, index: int) -> String:
	if place == ARMOR:
		return data.get(ARMOR, "")
	var spots := list(data, place)
	return spots[index] if index >= 0 and index < spots.size() else ""


static func set_id(data: Dictionary, place: String, index: int, id: String) -> void:
	if place == ARMOR:
		data[ARMOR] = id
	else:
		list(data, place)[index] = id


static func is_placed(data: Dictionary, id: String) -> bool:
	return id == id_at(data, ARMOR, 0) or id in list(data, HOTBAR) or id in list(data, BAG)


## Se dá para trocar o conteúdo de dois lugares: cada item precisa caber no lugar do outro.
static func can_move(data: Dictionary, from: String, from_index: int, to: String, to_index: int) -> bool:
	if from == to and from_index == to_index:
		return false
	var moving := load_item(id_at(data, from, from_index))
	return moving != null and fits(moving, to) and fits(load_item(id_at(data, to, to_index)), from)


## Troca o conteúdo de dois lugares. Devolve se trocou.
static func move(data: Dictionary, from: String, from_index: int, to: String, to_index: int) -> bool:
	if not can_move(data, from, from_index, to, to_index):
		return false
	var moving := id_at(data, from, from_index)
	set_id(data, from, from_index, id_at(data, to, to_index))
	set_id(data, to, to_index, moving)
	return true


## Põe um item no primeiro lugar livre: a armadura veste se Nate estiver sem nenhuma; as armas e a poção vão para a
## barra; o resto, e o que não couber na barra, para a mochila. Devolve se mudou algum lugar.
static func place(data: Dictionary, id: String) -> bool:
	var item := load_item(id)
	if item == null or is_placed(data, id):
		return false
	if item is ArmorData and id_at(data, ARMOR, 0) == "":
		set_id(data, ARMOR, 0, id)
		return true
	for spot_place in ([HOTBAR, BAG] if is_hand_item(item) else [BAG]):
		var free := list(data, spot_place).find("")
		if free >= 0:
			set_id(data, spot_place, free, id)
			return true
	push_warning("Sem lugar para o item %s." % id)
	return false
