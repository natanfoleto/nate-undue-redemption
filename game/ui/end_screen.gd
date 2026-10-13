class_name EndScreen
extends ColorRect
## Fim da parte jogável: a tela escurece, mostra para onde o elevador leva e volta ao menu principal
## no próximo botão apertado.

## Tempo para escurecer e tempo até aceitar o botão, em segundos.
@export var fade_time := 0.0
@export var wait_time := 0.0

var _ready_to_leave := false

@onready var _label: Label = $Label


func _ready() -> void:
	visible = false
	modulate.a = 0.0
	_label.text = tr(&"SLICE_END")


func show_end() -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property(self, ^"modulate:a", 1.0, fade_time)
	tween.tween_interval(wait_time)
	tween.tween_callback(func() -> void: _ready_to_leave = true)


func _input(event: InputEvent) -> void:
	if _ready_to_leave and event.is_pressed() and not event.is_echo():
		get_tree().change_scene_to_file("res://main.tscn")
