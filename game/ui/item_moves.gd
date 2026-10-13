class_name ItemMoves
## As trocas de lugar do inventário (09-interface): os itens entre a barra fixa, a mochila e a armadura; os elementos
## entre a lista dos aprendidos e os 2 espaços de elemento.

const ITEM_PLACES: Array[String] = [GameState.HOTBAR, GameState.BAG, GameState.ARMOR]


static func can_drop(from: ItemCell, to: ItemCell) -> bool:
	if from == to or from.item == null:
		return false
	if from.place in ITEM_PLACES and to.place in ITEM_PLACES:
		return GameState.can_move(from.place, from.index, to.place, to.index)
	if from.place == ItemCell.LEARNED:
		return to.place == ItemCell.ELEMENT
	if from.place == ItemCell.ELEMENT:
		return to.place == ItemCell.ELEMENT or to.place == ItemCell.LEARNED
	return false


## Troca os dois espaços. Um elemento solto na lista dos aprendidos sai do espaço dele.
static func drop(from: ItemCell, to: ItemCell) -> void:
	if not can_drop(from, to):
		AudioManager.play(&"ui_back")
		return
	if from.place in ITEM_PLACES:
		GameState.move(from.place, from.index, to.place, to.index)
	elif to.place == ItemCell.ELEMENT:
		GameState.equip_element(to.index, GameState.item_id(from.item))
	else:
		GameState.unequip_element(from.index)
	AudioManager.play(&"ui_confirm")
