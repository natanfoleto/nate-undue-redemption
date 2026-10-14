class_name MemoryScene
extends CanvasLayer
## Memória do herói antigo (10-arte-audio): cena curta feita no motor, sem fala, mostrada na primeira visita a
## um santuário. Um pequeno cenário de blocos com a câmera em movimento; qualquer botão pula depois de um tempo.

signal finished

## Duração da cena e tempo mínimo antes de poder pular, em segundos.
@export var duration := 0.0
@export var min_time := 0.0
## Tempo da tela escurecendo e clareando, em segundos.
@export var fade_time := 0.0
## A câmera vai de um ponto ao outro durante a cena.
@export var camera_from: Marker3D
@export var camera_to: Marker3D
## Quem anda pela cena (a memória 2), de um ponto ao outro.
@export var walker: Node3D
@export var walker_to: Marker3D

var _can_skip := false
var _ending := false

@onready var _camera: Camera3D = %Camera
@onready var _fade: ColorRect = %Fade
@onready var _view: TextureRect = %View
@onready var _stage_view: SubViewport = %SubViewport


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_stage_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.texture = _stage_view.get_texture()
	_fit_view()
	get_viewport().size_changed.connect(_fit_view)
	AudioManager.push_music(AudioManager.rules.memory_music)
	_camera.global_transform = camera_from.global_transform
	_fade.color.a = 1.0
	var tween := create_tween().set_parallel()
	tween.tween_property(_fade, ^"color:a", 0.0, fade_time)
	tween.tween_property(_camera, ^"global_transform", camera_to.global_transform, duration)
	if walker and walker_to:
		tween.tween_property(walker, ^"global_position", walker_to.global_position, duration)
	tween.tween_callback(func() -> void: _can_skip = true).set_delay(min_time)
	tween.chain().tween_callback(_end)


# O cenário é desenhado com os pixels da janela: a interface cresce com a janela, mas o 3D não pode perder nitidez.
func _fit_view() -> void:
	var pixels := get_viewport().get_visible_rect().size * get_viewport().get_final_transform().get_scale()
	_stage_view.size = Vector2i(pixels.round())


func _unhandled_input(event: InputEvent) -> void:
	if not _can_skip or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_end()


func _end() -> void:
	if _ending:
		return
	_ending = true
	var tween := create_tween()
	tween.tween_property(_fade, ^"color:a", 1.0, fade_time)
	await tween.finished
	get_tree().paused = false
	AudioManager.pop_music()
	finished.emit()
	queue_free()
