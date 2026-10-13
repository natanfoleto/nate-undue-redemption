class_name MuralView
extends CanvasLayer
## O mural grande na tela (09-interface): sem texto, numa moldura escura. Fecha com qualquer botão, depois de um
## tempo mínimo. Para o jogo enquanto está aberto (na galeria, o jogo já está parado).

signal done

## Tempo para aparecer e tempo mínimo na tela, em segundos.
@export var fade_time := 0.0
@export var min_time := 0.0

var _can_close := false
var _was_paused := false

@onready var _picture: TextureRect = %Picture
@onready var _shade: Control = %Shade


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_image(texture: Texture2D) -> void:
	_was_paused = get_tree().paused
	get_tree().paused = true
	_picture.texture = texture
	_shade.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_shade, ^"modulate:a", 1.0, fade_time)
	tween.tween_interval(min_time)
	tween.tween_callback(func() -> void: _can_close = true)
	await done


func _input(event: InputEvent) -> void:
	if not visible or not event.is_pressed() or event.is_echo():
		return
	get_viewport().set_input_as_handled()
	if not _can_close:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_can_close = false
		var tween := create_tween()
		tween.tween_property(_shade, ^"modulate:a", 0.0, fade_time)
		await tween.finished
		get_tree().paused = _was_paused
		done.emit()
		queue_free()
