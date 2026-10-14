class_name BossBar
extends Control
## Barra do chefe (09-interface): no alto, ao centro, com o nome em cima. Na fase 1, a vida da Boiúna dividida nas
## partes; a parte que espera um pilar aceso fica cinza. Na fase 2, uma barra só. Aparece quando a luta começa e some
## quando ela acaba. A vida perdida fica clara um instante, como na barra de Nate.

## Tamanho da barra inteira e o vão entre as partes, em pixels da tela.
@export var bar_size := Vector2.ZERO
@export var gap := 0
@export var border_width := 0
@export var back_color := Color.BLACK
@export var fill_color := Color.WHITE
## A cor da parte travada, esperando um pilar.
@export var locked_color := Color.WHITE
@export var lost_color := Color.WHITE
@export var border_color := Color.WHITE
@export var shine_share := 0.0
@export var shine_color := Color.WHITE
## A vida perdida: quanto tempo ela espera e a velocidade com que some, em pontos por segundo.
@export var lost_delay := 0.0
@export var lost_speed := 0.0
## O nome em cima da barra: a chave na tabela de tradução, o tamanho, o contorno e o espaço até a barra.
@export var name_key: StringName
@export var font_size := 0
@export var outline_size := 0
@export var name_gap := 0
## Tempo para aparecer e sumir, em segundos.
@export var fade_time := 0.0

var _boss: Boiuna
var _value := 0
var _shown_lost := 0.0
var _lost_wait := 0.0
var _tween: Tween


func _ready() -> void:
	add_to_group(&"boss_bar")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	visible = false


## Mostra a barra com a vida de [param boss].
func track(boss: Boiuna) -> void:
	_boss = boss
	_value = boss.health.value
	_shown_lost = _value
	visible = true
	_fade(1.0)


## Some aos poucos (a luta acabou ou recomeçou).
func release() -> void:
	_fade(0.0)


func _fade(alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"modulate:a", alpha, fade_time)
	if alpha == 0.0:
		_tween.tween_callback(hide)


func _process(delta: float) -> void:
	if _boss == null or not visible:
		return
	var value := _boss.health.value
	if value < _value:
		_lost_wait = lost_delay
	elif value > _value:
		_shown_lost = value
	_value = value
	if _shown_lost > _value:
		if _lost_wait > 0.0:
			_lost_wait -= delta
		else:
			_shown_lost = maxf(_shown_lost - lost_speed * delta, _value)
	queue_redraw()


func _draw() -> void:
	if _boss == null:
		return
	var font := get_theme_default_font()
	var title := tr(name_key)
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var title_at := Vector2(-title_size.x / 2.0, font.get_ascent(font_size))
	draw_string_outline(font, title_at, title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline_size, Color.BLACK)
	draw_string(font, title_at, title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	var max_value := _boss.health.max_value
	if max_value <= 0:
		return
	var parts := _boss.data.parts if _boss.phase == Boiuna.Phase.ONE else 1
	var part_value := float(max_value) / parts
	var part_width := (bar_size.x - gap * (parts - 1)) / parts
	var top := font.get_height(font_size) + name_gap
	# A parte que cai a seguir: na fase 1, cinza enquanto espera um pilar.
	var next := ceili(_value / part_value) - 1
	for i in parts:
		var outer := Rect2(Vector2(-bar_size.x / 2.0 + i * (part_width + gap), top), Vector2(part_width, bar_size.y))
		draw_rect(outer, border_color)
		var inner := outer.grow(-border_width)
		draw_rect(inner, back_color)
		var lost := inner
		lost.size.x = inner.size.x * clampf((_shown_lost - i * part_value) / part_value, 0.0, 1.0)
		draw_rect(lost, lost_color)
		var fill := inner
		fill.size.x = inner.size.x * clampf((_value - i * part_value) / part_value, 0.0, 1.0)
		draw_rect(fill, locked_color if i == next and _boss.is_locked() else fill_color)
		draw_rect(Rect2(fill.position, Vector2(fill.size.x, maxf(inner.size.y * shine_share, 1.0))), shine_color)
