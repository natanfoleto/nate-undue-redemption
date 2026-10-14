class_name Credits
extends CanvasLayer
## Créditos (02-core-loop, 10-arte-audio): depois da cena final, os nomes sobem devagar pela tela: o jogo, quem o fez
## e os pacotes prontos usados. Segurar qualquer botão acelera. No fim, a última linha para no meio da tela e a tela
## escurece.

signal finished

## As linhas, na ordem, pelas chaves da tabela de tradução: a primeira é o nome do jogo; as de [member headings] são
## os títulos das partes.
@export var lines: Array[StringName] = []
@export var headings: Array[StringName] = []
## Tamanho das letras do nome do jogo, dos títulos e das linhas, e o espaço entre as linhas, em pixels.
@export var title_size := 0
@export var heading_size := 0
@export var line_size := 0
@export var heading_color := Color.WHITE
## Velocidade da subida, em pixels por segundo, normal e com um botão segurado.
@export var speed := 0.0
@export var fast_speed := 0.0
## Tempo da tela clareando e escurecendo, e o tempo parado no fim, em segundos.
@export var fade_time := 0.0
@export var end_hold := 0.0

var _ending := false

@onready var _roll: VBoxContainer = %Roll
@onready var _fade: ColorRect = %Fade


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	for i in lines.size():
		var label := Label.new()
		label.text = tr(lines[i])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var size := title_size if i == 0 else heading_size if lines[i] in headings else line_size
		label.add_theme_font_size_override(&"font_size", size)
		if lines[i] in headings:
			label.add_theme_color_override(&"font_color", heading_color)
		_roll.add_child(label)
	_roll.position.y = _screen_height()
	create_tween().tween_property(_fade, ^"color:a", 0.0, fade_time)


func _process(delta: float) -> void:
	if _ending:
		return
	_roll.position.y -= (fast_speed if Input.is_anything_pressed() else speed) * delta
	# Para quando a última linha chega ao meio da tela.
	var last := _roll.get_child(_roll.get_child_count() - 1) as Control
	var last_middle := _roll.position.y + last.position.y + last.size.y / 2.0
	if last_middle <= _screen_height() / 2.0:
		_end()


func _screen_height() -> float:
	return get_viewport().get_visible_rect().size.y


func _end() -> void:
	_ending = true
	var tween := create_tween()
	tween.tween_interval(end_hold)
	tween.tween_property(_fade, ^"color:a", 1.0, fade_time)
	await tween.finished
	finished.emit()
	queue_free()
