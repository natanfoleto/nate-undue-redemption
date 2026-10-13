class_name ItemCell
extends Button
## Um espaço de item (09-interface): na barra fixa, na mochila, na armadura e nos elementos do inventário. Mostra o
## ícone com a moldura da raridade, o número do espaço da barra, as cargas da poção e se o item está na mão.
## Arrastar e soltar troca os itens de lugar (ItemMoves); clicar pega o item e clicar em outro espaço o solta ali.

## Lugares que não guardam itens: os 2 espaços de elemento e a lista dos elementos aprendidos.
const ELEMENT := "element"
const LEARNED := "learned"

@export var look: CellLook

## O lugar e o índice do espaço (GameState.HOTBAR, BAG, ARMOR, ou ELEMENT e LEARNED).
var place := ""
var index := 0
## O item ou o elemento no espaço, ou nulo.
var item: Resource:
	set(value):
		item = value
		queue_redraw()
## Número do espaço na barra (1 a 5); 0 não mostra.
var number := 0:
	set(value):
		number = value
		queue_redraw()
## Texto embaixo, à direita (as cargas da poção).
var count_text := "":
	set(value):
		count_text = value
		queue_redraw()
## É o item da mão.
var in_hand := false:
	set(value):
		in_hand = value
		queue_redraw()
## Está sendo levado para outro espaço (teclado e controle).
var carried := false:
	set(value):
		carried = value
		queue_redraw()

var _hovered := false


func _ready() -> void:
	custom_minimum_size = Vector2.ONE * look.size
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for state in [&"normal", &"hover", &"pressed", &"focus", &"disabled", &"hover_pressed"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var marajoara: bool = item is ItemData and (item as ItemData).marajoara
	if marajoara:
		draw_rect(rect.grow(look.glow_width), Color(look.marajoara_color, 0.35))
	draw_rect(rect, look.back_color)
	var frame := look.empty_color
	if item:
		frame = look.marajoara_color if marajoara else look.common_color
	var width := look.frame_width
	if in_hand:
		frame = look.hand_color
		width = look.hand_width
	if has_focus() or _hovered:
		frame = look.focus_color
	draw_rect(rect.grow(-width / 2.0), frame, false, width)
	var texture := _icon()
	if texture:
		var icon_size := texture.get_size() * look.icon_scale
		var tint := Color(1, 1, 1, look.carried_alpha if carried else 1.0)
		draw_texture_rect(texture, Rect2((size - icon_size) / 2.0, icon_size), false, tint)
	var font := get_theme_default_font()
	var margin := width + look.text_margin
	if number > 0:
		_draw_text(font, str(number), Vector2(margin, look.font_size + width), HORIZONTAL_ALIGNMENT_LEFT)
	if count_text != "":
		_draw_text(font, count_text, Vector2(size.x - margin, size.y - margin), HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_text(font: Font, text: String, at: Vector2, alignment: HorizontalAlignment) -> void:
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, look.font_size).x
	var start := at - Vector2(text_width if alignment == HORIZONTAL_ALIGNMENT_RIGHT else 0.0, 0.0)
	draw_string_outline(font, start, text, HORIZONTAL_ALIGNMENT_LEFT, -1, look.font_size, look.text_outline, Color.BLACK)
	draw_string(font, start, text, HORIZONTAL_ALIGNMENT_LEFT, -1, look.font_size, Color.WHITE)


func _icon() -> Texture2D:
	return item.get(&"icon") as Texture2D if item else null


func _set_hovered(on: bool) -> void:
	_hovered = on
	queue_redraw()


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null or mouse_filter == MOUSE_FILTER_IGNORE:
		return null
	var preview := TextureRect.new()
	preview.texture = _icon()
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = preview.texture.get_size() * look.icon_scale
	preview.position = -preview.size / 2.0
	var holder := Control.new()
	holder.add_child(preview)
	set_drag_preview(holder)
	return {"cell": self}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and (data as Dictionary).get("cell") is ItemCell and ItemMoves.can_drop(data["cell"], self)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	ItemMoves.drop(data["cell"], self)
