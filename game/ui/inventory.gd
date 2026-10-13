class_name Inventory
extends CanvasLayer
## Inventário (09-interface): à esquerda, Nate e os 5 espaços; à direita, os itens da categoria escolhida;
## embaixo, os detalhes do item e a comparação com o equipado, atributo por atributo, com seta verde (melhor)
## ou vermelha (pior). Abre com o botão de inventário e para o jogo enquanto está aberto.

## Nome de cada um dos 5 espaços, na ordem da tela (05-itens): os 3 de equipamento e os 2 de elemento.
const SLOT_KEYS := [&"SLOT_MELEE", &"SLOT_RANGED", &"SLOT_ARMOR", &"SLOT_ELEMENT_1", &"SLOT_ELEMENT_2"]

@export var heart_full: Texture2D
@export var heart_empty: Texture2D
@export var flask_icon: Texture2D
## O muiraquitã, sem e com a lasca (o Selo).
@export var amulet_icon: Texture2D
@export var amulet_whole_icon: Texture2D
## Quantas vezes os ícones de 16 px são ampliados, e o tamanho de cada item da lista, em pixels da tela.
@export var icon_scale := 1
@export var item_size := 0
## Espessura da moldura, normal e com o foco, e do brilho marajoara, em pixels da tela.
@export var frame_width := 0
@export var focus_width := 0
@export var glow_size := 0
## Transparência do muiraquitã ainda adormecido.
@export var asleep_alpha := 0.0
## Molduras (10-arte-audio): marajoara em verde-jade; comum em cinza. O fundo de cada item.
@export var marajoara_color := Color.WHITE
@export var common_color := Color.WHITE
@export var item_back := Color.BLACK
## Setas da comparação: melhor e pior.
@export var better_color := Color.WHITE
@export var worse_color := Color.WHITE
## Tamanho do texto dos espaços e dos atributos, em pixels da tela.
@export var font_size := 0

var _slot := 0
var _slot_buttons: Array[Button] = []
# Os 3 espaços de equipamento do GameState; os 2 de elemento vêm depois.
var _equipment_slots: Array[String] = [GameState.MELEE, GameState.RANGED, GameState.ARMOR]

@onready var _panel: Control = %Panel
@onready var _hearts: HBoxContainer = %Hearts
@onready var _flask: Label = %FlaskCharges
@onready var _flask_box: Control = %FlaskBox
@onready var _amulet: TextureRect = %Amulet
@onready var _slot_list: VBoxContainer = %SlotList
@onready var _combo: Label = %Combo
@onready var _category: Label = %Category
@onready var _items: GridContainer = %Items
@onready var _item_name: Label = %ItemName
@onready var _stats: GridContainer = %Stats


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	(%NateTitle as Label).text = tr(&"INVENTORY_NATE")
	for i in SLOT_KEYS.size():
		var button := Button.new()
		button.add_theme_font_size_override(&"font_size", font_size)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = false
		button.pressed.connect(_open_slot.bind(i))
		button.focus_entered.connect(_on_slot_focused.bind(i))
		_slot_list.add_child(button)
		_slot_buttons.append(button)


# Fechar vem antes da interface: o botão em foco usaria o Tab para trocar de foco.
func _input(event: InputEvent) -> void:
	if _panel.visible and (event.is_action_pressed(&"inventory") or event.is_action_pressed(&"pause")):
		get_viewport().set_input_as_handled()
		_close()


func _unhandled_input(event: InputEvent) -> void:
	if _panel.visible:
		if event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			if _items.get_children().any(func(item: Control) -> bool: return item.has_focus()):
				_slot_buttons[_slot].grab_focus()
			else:
				_close()
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
	_refresh()
	_open_slot(_slot)
	_slot_buttons[_slot].grab_focus()


func _close() -> void:
	AudioManager.play(&"ui_close")
	_panel.visible = false
	get_tree().paused = false


func _refresh() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	for heart in _hearts.get_children():
		heart.free()
	for i in player.health.max_value:
		_hearts.add_child(_icon(heart_full if i < player.health.value else heart_empty))
	_flask_box.visible = GameState.has_flask()
	_flask.text = "%d/%d" % [player.flask.charges, player.flask.max_charges]
	_amulet.texture = amulet_whole_icon if GameState.has_seal() else amulet_icon
	_amulet.modulate.a = 1.0 if GameState.has_light() else asleep_alpha
	for i in SLOT_KEYS.size():
		var equipped := _equipped(i)
		_slot_buttons[i].text = "%s: %s" % [tr(SLOT_KEYS[i]), tr(equipped.name_key) if equipped else tr(&"SLOT_EMPTY")]
		_slot_buttons[i].icon = equipped.icon if equipped else null
	_show_combo()


# Com os 2 elementos escolhidos, a tela mostra a combinação que eles formam (09-interface).
func _show_combo() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	var spell := player.spells.combos.find(GameState.equipped_element_id(0), GameState.equipped_element_id(1))
	_combo.visible = spell != null
	if spell:
		_combo.text = "%s: %s" % [tr(&"INVENTORY_COMBO"), tr(spell.name_key)]


func _on_slot_focused(index: int) -> void:
	if _slot != index:
		_open_slot(index)


func _open_slot(index: int) -> void:
	_slot = index
	_category.text = tr(SLOT_KEYS[index])
	for item in _items.get_children():
		item.free()
	for option in _options(index):
		var button := Button.new()
		button.icon = option.icon
		button.tooltip_text = tr(option.name_key)
		button.custom_minimum_size = Vector2.ONE * item_size
		button.expand_icon = true
		button.add_theme_stylebox_override(&"normal", _frame(option, false))
		button.add_theme_stylebox_override(&"focus", _frame(option, true))
		button.add_theme_stylebox_override(&"hover", _frame(option, true))
		button.pressed.connect(_choose.bind(option))
		button.focus_entered.connect(_show_details.bind(option))
		_items.add_child(button)
	_show_details(_equipped(index))


# O que dá para pôr no espaço: os itens guardados da categoria, ou os elementos aprendidos.
func _options(index: int) -> Array[Resource]:
	if index < _equipment_slots.size():
		return GameState.owned(_equipment_slots[index])
	var list: Array[Resource] = []
	for id: String in GameState.learned_elements():
		list.append(load(GameState.ELEMENTS_FOLDER + id + ".tres"))
	return list


func _choose(option: Resource) -> void:
	if _slot < _equipment_slots.size():
		GameState.equip(_equipment_slots[_slot], GameState.item_id(option))
	else:
		GameState.equip_element(_slot - _equipment_slots.size(), GameState.item_id(option))
	_refresh()
	_slot_buttons[_slot].grab_focus()


func _equipped(index: int) -> Resource:
	if index < _equipment_slots.size():
		return GameState.equipped(_equipment_slots[index])
	return GameState.equipped_element(index - _equipment_slots.size())


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
	var current := _equipped(_slot)
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


func _frame(option: Resource, focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = item_back
	var marajoara: bool = option is ItemData and option.marajoara
	style.border_color = marajoara_color if marajoara else common_color
	style.set_border_width_all(focus_width if focused else frame_width)
	if marajoara:
		style.shadow_color = marajoara_color
		style.shadow_size = glow_size
	return style


func _icon(texture: Texture2D) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = texture.get_size() * icon_scale
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	return icon
