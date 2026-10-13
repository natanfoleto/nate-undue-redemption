class_name ScrollView
extends CanvasLayer
## O pergaminho aberto na tela (05-itens, 10-arte-audio): o rolo se abre e mostra o desenho do elemento, sem
## texto. Fecha com qualquer botão, depois de um tempo mínimo.

signal done

## Tempo do rolo abrindo e tempo mínimo aberto, em segundos.
@export var open_time := 0.0
@export var min_time := 0.0

var _can_close := false

@onready var _paper: Control = %Paper
@onready var _drawing: TextureRect = %Drawing


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Abre o rolo com o desenho do elemento e espera fechar.
func show_element(element: ElementData) -> void:
	get_tree().paused = true
	_drawing.texture = element.drawing
	_paper.pivot_offset = _paper.size / 2.0
	_paper.scale = Vector2(0.0, 1.0)
	var tween := create_tween()
	tween.tween_property(_paper, ^"scale:x", 1.0, open_time)
	tween.tween_interval(min_time)
	tween.tween_callback(func() -> void: _can_close = true)
	await done


func _unhandled_input(event: InputEvent) -> void:
	if not _can_close or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_can_close = false
		var tween := create_tween()
		tween.tween_property(_paper, ^"scale:x", 0.0, open_time)
		await tween.finished
		get_tree().paused = false
		done.emit()
		queue_free()
