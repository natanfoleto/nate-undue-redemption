class_name HealthBar
extends Control
## Barra de vida de Nate no HUD (09-interface): o comprimento acompanha a vida máxima, então a armadura e as
## melhorias a deixam mais longa. A vida perdida fica clara um instante e depois some; o número fica em cima.

## Comprimento por ponto de vida e altura, em pixels da tela.
@export var width_per_point := 0.0
@export var bar_height := 0
@export var border_width := 0
@export var back_color := Color.BLACK
@export var fill_color := Color.WHITE
## A cor da barra com pouca vida (abaixo desta parte da máxima).
@export var low_color := Color.WHITE
@export var low_share := 0.0
## A vida perdida: a cor, quanto tempo ela espera e a velocidade com que some, em pontos por segundo.
@export var lost_color := Color.WHITE
@export var lost_delay := 0.0
@export var lost_speed := 0.0
@export var border_color := Color.WHITE
## O brilho fino no alto da vida: a parte da altura e a cor.
@export var shine_share := 0.0
@export var shine_color := Color.WHITE
## O número em cima da barra: o tamanho e o contorno escuro, em pixels da tela.
@export var font_size := 0
@export var outline_size := 0

var _value := 0
var _max_value := 0
var _shown_lost := 0.0
var _lost_wait := 0.0


func show_value(value: int, max_value: int) -> void:
	if value < _value:
		_lost_wait = lost_delay
	else:
		_shown_lost = minf(_shown_lost, value)
	_shown_lost = maxf(_shown_lost, value)
	_value = value
	_max_value = max_value
	custom_minimum_size = Vector2(max_value * width_per_point + 2 * border_width, bar_height)
	queue_redraw()


func _process(delta: float) -> void:
	if _shown_lost <= _value:
		return
	if _lost_wait > 0.0:
		_lost_wait -= delta
		return
	_shown_lost = maxf(_shown_lost - lost_speed * delta, _value)
	queue_redraw()


func _draw() -> void:
	var outer := Rect2(Vector2.ZERO, custom_minimum_size)
	draw_rect(outer, border_color)
	var inner := outer.grow(-border_width)
	draw_rect(inner, back_color)
	if _max_value <= 0:
		return
	var lost := inner
	lost.size.x = inner.size.x * _shown_lost / _max_value
	draw_rect(lost, lost_color)
	var fill := inner
	fill.size.x = inner.size.x * _value / _max_value
	draw_rect(fill, low_color if _value <= _max_value * low_share else fill_color)
	# Um brilho fino no alto, para a barra não ficar chapada.
	draw_rect(Rect2(fill.position, Vector2(fill.size.x, maxf(inner.size.y * shine_share, 1.0))), shine_color)
	var font := get_theme_default_font()
	var text := "%d / %d" % [_value, _max_value]
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var at := Vector2((outer.size.x - text_size.x) / 2.0, (outer.size.y + font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0)
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline_size, Color.BLACK)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
