class_name Inventory
extends CanvasLayer
## Inventário (09-interface), parecido com o do Minecraft: uma caixa de tamanho fixo no centro da tela. Em cima, a
## armadura vestida e os 2 elementos ao lado de Nate (o boneco, com o item da mão e a armadura) e, à direita, a vida,
## a poção, o muiraquitã e a combinação dos elementos; embaixo, a mochila, os elementos aprendidos, a barra fixa e a
## ajuda. Os detalhes do item apontado aparecem numa caixinha ao lado dele, com a comparação com o que Nate usa,
## atributo por atributo, com seta verde (melhor) ou vermelha (pior). Arrastar troca os itens de lugar; clicar pega
## o item e clicar em outro espaço o solta ali (o mesmo com o botão de confirmar, no teclado e no controle); os
## números põem o item apontado na barra. Abre com o botão de inventário e para o jogo; a barra fixa do HUD some
## enquanto ele está aberto, porque a dele toma o lugar.

@export var look: CellLook
## O muiraquitã, sem e com a lasca (o Selo).
@export var amulet_icon: Texture2D
@export var amulet_whole_icon: Texture2D
## Ícones apagados dos espaços vazios da armadura e dos elementos.
@export var armor_placeholder: Texture2D
@export var element_placeholder: Texture2D
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1
## Transparência do muiraquitã ainda adormecido.
@export var asleep_alpha := 0.0
## Setas da comparação: melhor e pior.
@export var better_color := Color.WHITE
@export var worse_color := Color.WHITE
## Cor do nome do item comum (o marajoara usa a cor da moldura dele).
@export var common_name_color := Color.WHITE
## Tamanho do texto dos atributos, em pixels da tela.
@export var font_size := 0
## Distância dos detalhes até o espaço apontado e até a borda da tela, em pixels da tela.
@export var details_gap := 0.0
@export var screen_margin := 0.0

var _bag: Array[ItemCell] = []
var _armor: ItemCell
var _elements: Array[ItemCell] = []
var _hotbar: Array[ItemCell] = []
var _hud_hotbar: Hotbar
# O espaço com o item sendo levado (clique ou confirmar) e o espaço apontado (mouse em cima ou foco).
var _carried: ItemCell
var _pointed: ItemCell

@onready var _panel: Control = %Panel
@onready var _preview: NatePreview = %Preview
@onready var _life: Label = %Life
@onready var _potion: Label = %Potion
@onready var _amulet: TextureRect = %Amulet
@onready var _amulet_name: Label = %AmuletName
@onready var _combo: Label = %Combo
@onready var _learned_title: Label = %LearnedTitle
@onready var _learned: GridContainer = %Learned
@onready var _details: Control = %Details
@onready var _item_name: Label = %ItemName
@onready var _rarity: Label = %Rarity
@onready var _stats: GridContainer = %Stats
@onready var _help: Label = %Help


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_details.visible = false
	(%Title as Label).text = tr(&"INVENTORY_TITLE")
	(%BagTitle as Label).text = tr(&"INVENTORY_BAG")
	_learned_title.text = tr(&"INVENTORY_LEARNED")
	_amulet_name.text = tr(&"INVENTORY_AMULET")
	_armor = _new_cell(%Gear, GameState.ARMOR, 0)
	_armor.placeholder = armor_placeholder
	_armor.slot_key = &"SLOT_ARMOR"
	for i in 2:
		var element := _new_cell(%Gear, ItemCell.ELEMENT, i)
		element.placeholder = element_placeholder
		element.slot_key = &"SLOT_ELEMENT"
		_elements.append(element)
	for i in GameState.BAG_SIZE:
		_bag.append(_new_cell(%Bag, GameState.BAG, i))
	for i in GameState.HOTBAR_SIZE:
		var cell := _new_cell(%HotbarRow, GameState.HOTBAR, i)
		cell.number = i + 1
		_hotbar.append(cell)
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
	_hud_hotbar = get_tree().get_first_node_in_group(&"hotbar") as Hotbar
	if _hud_hotbar:
		_hud_hotbar.visible = false
	_preview.set_active(true)
	_refresh()
	_show_help()
	# O foco começa no item da mão; com o mouse, os detalhes só aparecem quando ele passa por cima de um item.
	var hand := _hotbar[GameState.hand()]
	hand.grab_focus()
	if not InputManager.is_gamepad():
		_unpoint(hand)


func _close() -> void:
	AudioManager.play(&"ui_close")
	_drop_carried()
	_pointed = null
	_details.visible = false
	_preview.set_active(false)
	if _hud_hotbar:
		_hud_hotbar.visible = true
	_panel.visible = false
	get_tree().paused = false


# A caixinha dos detalhes acompanha o espaço apontado depois que a caixa do inventário se arruma na tela.
func _process(_delta: float) -> void:
	if _details.visible:
		_place_details()


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
	_amulet_name.modulate.a = _amulet.modulate.a
	for cell in _bag:
		cell.item = GameState.item_at(GameState.BAG, cell.index)
	_armor.item = GameState.worn_armor()
	for cell in _elements:
		cell.item = GameState.equipped_element(cell.index)
	Hotbar.show_slots(_hotbar, player)
	_show_learned()
	_show_combo(player)
	_preview.dress(GameState.hand_item(), GameState.worn_armor())
	_show_details(_pointed)


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
	cell.pressed.connect(_on_cell_pressed.bind(cell))
	cell.focus_entered.connect(_point.bind(cell))
	cell.mouse_entered.connect(_point.bind(cell))
	cell.mouse_exited.connect(_unpoint.bind(cell))
	return cell


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
	if _pointed == null or _pointed.item == null:
		return
	_drop_carried()
	ItemMoves.drop(_pointed, _hotbar[slot])


func _point(cell: ItemCell) -> void:
	_pointed = cell
	_show_details(cell)


# O mouse saiu do espaço: os detalhes somem (com o teclado e o controle, eles seguem o foco).
func _unpoint(cell: ItemCell) -> void:
	if _pointed == cell:
		_pointed = null
		_details.visible = false


# Os detalhes do item apontado, na caixinha ao lado do espaço; no espaço vazio da armadura e dos elementos, o nome
# do espaço.
func _show_details(cell: ItemCell) -> void:
	for child in _stats.get_children():
		child.free()
	var option: Resource = cell.item if cell else null
	if option == null:
		_details.visible = cell != null and cell.slot_key != &""
		if _details.visible:
			_item_name.text = tr(cell.slot_key)
			_item_name.modulate = common_name_color
			_rarity.visible = false
			_details.reset_size()
		return
	var marajoara: bool = option is ItemData and (option as ItemData).marajoara
	_item_name.text = tr(option.name_key)
	_item_name.modulate = look.marajoara_color if marajoara else common_name_color
	_rarity.visible = option is ItemData
	_rarity.text = tr(&"RARITY_MARAJOARA" if marajoara else &"RARITY_COMMON")
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
	_details.visible = true
	_details.reset_size()


# Ao lado do espaço apontado, à direita; sem lugar, à esquerda. Sempre dentro da tela.
func _place_details() -> void:
	if _pointed == null or not _details.visible:
		return
	var cell := _pointed.get_global_rect()
	var screen := _panel.get_viewport_rect().size
	var spot := Vector2(cell.end.x + details_gap, cell.position.y)
	if spot.x + _details.size.x > screen.x - screen_margin:
		spot.x = cell.position.x - details_gap - _details.size.x
	spot.y = clampf(spot.y, screen_margin, screen.y - screen_margin - _details.size.y)
	_details.position = spot


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
