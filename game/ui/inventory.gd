class_name Inventory
extends CanvasLayer
## Inventário (09-interface): uma caixa no centro da tela. À esquerda, Nate: a vida, a poção, o muiraquitã, a
## armadura vestida e os 2 elementos; no meio, a mochila e os elementos aprendidos; à direita, os detalhes do item
## e a comparação com o que Nate usa, atributo por atributo, com seta verde (melhor) ou vermelha (pior). A barra
## fixa continua embaixo, por cima da caixa. Arrastar troca os itens de lugar; clicar pega o item e clicar em outro
## espaço o solta ali (o mesmo com o botão de confirmar, no teclado e no controle); os números põem o item apontado
## na barra. Abre com o botão de inventário e para o jogo enquanto está aberto.

@export var look: CellLook
## O muiraquitã, sem e com a lasca (o Selo).
@export var amulet_icon: Texture2D
@export var amulet_whole_icon: Texture2D
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1
## Transparência do muiraquitã ainda adormecido.
@export var asleep_alpha := 0.0
## Setas da comparação: melhor e pior.
@export var better_color := Color.WHITE
@export var worse_color := Color.WHITE
## Tamanho do texto dos atributos, em pixels da tela.
@export var font_size := 0

var _bag: Array[ItemCell] = []
var _armor: ItemCell
var _elements: Array[ItemCell] = []
var _hotbar: Hotbar
# O espaço com o item sendo levado (clique ou confirmar) e o último espaço apontado (mouse ou foco).
var _carried: ItemCell
var _pointed: ItemCell

@onready var _panel: Control = %Panel
@onready var _life: Label = %Life
@onready var _potion: Label = %Potion
@onready var _amulet: TextureRect = %Amulet
@onready var _combo: Label = %Combo
@onready var _learned_title: Label = %LearnedTitle
@onready var _learned: HBoxContainer = %Learned
@onready var _item_name: Label = %ItemName
@onready var _stats: GridContainer = %Stats
@onready var _help: Label = %Help


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	(%Title as Label).text = tr(&"INVENTORY_TITLE")
	(%NateTitle as Label).text = tr(&"INVENTORY_NATE")
	(%ArmorTitle as Label).text = tr(&"SLOT_ARMOR")
	(%ElementsTitle as Label).text = tr(&"INVENTORY_ELEMENTS")
	(%BagTitle as Label).text = tr(&"INVENTORY_BAG")
	_learned_title.text = tr(&"INVENTORY_LEARNED")
	for i in GameState.BAG_SIZE:
		_bag.append(_new_cell(%Bag, GameState.BAG, i))
	_armor = _new_cell(%ArmorRow, GameState.ARMOR, 0)
	for i in 2:
		_elements.append(_new_cell(%ElementRow, ItemCell.ELEMENT, i))
	GameState.inventory_changed.connect(_refresh_if_open)
	GameState.elements_changed.connect(_refresh_if_open)
	GameState.hand_changed.connect(_refresh_if_open)
	InputManager.device_changed.connect(func(_device: int) -> void: _show_help())


# Fechar vem antes da interface: o botão em foco usaria o Tab para trocar de foco. Com um item levado, Esc só o larga.
func _input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if _carried and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_drop_carried()
	elif event.is_action_pressed(&"inventory") or event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_close()


func _unhandled_input(event: InputEvent) -> void:
	if _panel.visible:
		if event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			if _carried:
				_drop_carried()
			else:
				_close()
			return
		for i in Player.HOTBAR_ACTIONS.size():
			if event.is_action_pressed(Player.HOTBAR_ACTIONS[i]):
				get_viewport().set_input_as_handled()
				_send_to_hotbar(i)
		return
	if event.is_action_pressed(&"inventory") and not get_tree().paused:
		var player := get_tree().get_first_node_in_group(&"player") as Player
		if player and not player.is_dead() and not player.is_cinematic():
			get_viewport().set_input_as_handled()
			_open()


func _open() -> void:
	get_tree().paused = true
	AudioManager.play(&"ui_open")
	_panel.visible = true
	_hotbar = get_tree().get_first_node_in_group(&"hotbar") as Hotbar
	if _hotbar:
		_hotbar.set_interactive(true)
		_link_hotbar()
	_refresh()
	_show_help()
	var first := _hotbar.cells[GameState.hand()] if _hotbar else _bag[0]
	first.grab_focus()


func _close() -> void:
	AudioManager.play(&"ui_close")
	_drop_carried()
	if _hotbar:
		_hotbar.set_interactive(false)
	_panel.visible = false
	get_tree().paused = false


func _refresh_if_open() -> void:
	if _panel.visible:
		_refresh()


func _refresh() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	_life.text = "%s: %d / %d" % [tr(&"INVENTORY_LIFE"), player.health.value, player.health.max_value]
	_potion.visible = GameState.has_flask()
	_potion.text = "%s: %d / %d" % [tr(&"ITEM_FLASK"), player.flask.charges, player.flask.max_charges]
	_amulet.texture = amulet_whole_icon if GameState.has_seal() else amulet_icon
	_amulet.custom_minimum_size = _amulet.texture.get_size() * icon_scale
	_amulet.modulate.a = 1.0 if GameState.has_light() else asleep_alpha
	for cell in _bag:
		cell.item = GameState.item_at(GameState.BAG, cell.index)
	_armor.item = GameState.worn_armor()
	for cell in _elements:
		cell.item = GameState.equipped_element(cell.index)
	_show_learned()
	if _hotbar:
		_hotbar.refresh()
	_show_combo(player)
	_show_details(_pointed.item if _pointed else null)


# Os elementos aprendidos, para arrastar para os 2 espaços.
func _show_learned() -> void:
	var learned := GameState.learned_elements()
	_learned_title.visible = not learned.is_empty()
	_learned.visible = not learned.is_empty()
	while _learned.get_child_count() < learned.size():
		_new_cell(_learned, ItemCell.LEARNED, _learned.get_child_count())
	for cell: ItemCell in _learned.get_children():
		cell.item = load(GameState.ELEMENTS_FOLDER + learned[cell.index] + ".tres") if cell.index < learned.size() else null


# Com os 2 elementos escolhidos, a caixa mostra a combinação que eles formam (09-interface).
func _show_combo(player: Player) -> void:
	var spell := player.spells.combos.find(GameState.equipped_element_id(0), GameState.equipped_element_id(1))
	_combo.visible = spell != null
	if spell:
		_combo.text = "%s: %s" % [tr(&"INVENTORY_COMBO"), tr(spell.name_key)]


func _show_help() -> void:
	_help.text = tr(&"INVENTORY_HELP_GAMEPAD" if InputManager.is_gamepad() else &"INVENTORY_HELP_KEYBOARD")


func _new_cell(parent: Control, place: String, index: int) -> ItemCell:
	var cell := ItemCell.new()
	cell.look = look
	cell.place = place
	cell.index = index
	parent.add_child(cell)
	_link(cell)
	return cell


func _link(cell: ItemCell) -> void:
	cell.pressed.connect(_on_cell_pressed.bind(cell))
	cell.focus_entered.connect(_point.bind(cell))
	cell.mouse_entered.connect(_point.bind(cell))


# Os espaços da barra fixa entram no inventário: clique, foco e o caminho do foco entre a mochila e a barra.
func _link_hotbar() -> void:
	for cell in _hotbar.cells:
		if not cell.pressed.is_connected(_on_cell_pressed):
			_link(cell)
		var above := _bag[GameState.BAG_SIZE - 5 + cell.index]
		cell.focus_neighbor_top = cell.get_path_to(above)
		above.focus_neighbor_bottom = above.get_path_to(cell)


# Clique ou confirmar: o primeiro pega o item, o segundo o solta no espaço escolhido (ou devolve, no mesmo espaço).
func _on_cell_pressed(cell: ItemCell) -> void:
	if _carried == null:
		if cell.item:
			_carried = cell
			cell.carried = true
			AudioManager.play(&"ui_move")
		return
	var from := _carried
	_drop_carried()
	if from != cell:
		ItemMoves.drop(from, cell)


func _drop_carried() -> void:
	if _carried:
		_carried.carried = false
		_carried = null


# Os números põem o item apontado no espaço da barra com aquele número (ou trocam dois espaços da barra).
func _send_to_hotbar(slot: int) -> void:
	if _pointed == null or _pointed.item == null or _hotbar == null:
		return
	_drop_carried()
	ItemMoves.drop(_pointed, _hotbar.cells[slot])


func _point(cell: ItemCell) -> void:
	_pointed = cell
	_show_details(cell.item)


func _show_details(option: Resource) -> void:
	for cell in _stats.get_children():
		cell.free()
	if option == null:
		_item_name.text = ""
		return
	var rarity := ""
	if option is ItemData:
		rarity = " (%s)" % tr(&"RARITY_MARAJOARA" if option.marajoara else &"RARITY_COMMON")
	_item_name.text = tr(option.name_key) + rarity
	var current := _reference(option)
	for row in ItemStats.rows(option):
		var mine: Dictionary = row
		var other: Dictionary = {}
		if current and current != option:
			for candidate in ItemStats.rows(current):
				if candidate.key == mine.key:
					other = candidate
		_add_cell(tr(mine.key))
		_add_cell(mine.text)
		_add_comparison(mine, other)


# Com o que o item é comparado: a armadura vestida; para as armas, a da mão, se for do mesmo tipo, ou a primeira
# do mesmo tipo na barra.
func _reference(option: Resource) -> Resource:
	if option is ArmorData:
		return GameState.worn_armor()
	if not (option is MeleeWeaponData or option is RangedWeaponData):
		return null
	var held := GameState.hand_item()
	if held and held.get_script() == option.get_script():
		return held
	for i in GameState.HOTBAR_SIZE:
		var other := GameState.item_at(GameState.HOTBAR, i)
		if other and other.get_script() == option.get_script():
			return other
	return null


func _add_comparison(mine: Dictionary, other: Dictionary) -> void:
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", font_size)
	if not other.is_empty() and mine.has("value") and other.has("value") and mine.value != other.value:
		var better: bool = (mine.value > other.value) == mine.higher_is_better
		label.text = "▲" if better else "▼"
		label.modulate = better_color if better else worse_color
	_stats.add_child(label)


func _add_cell(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", font_size)
	_stats.add_child(label)
