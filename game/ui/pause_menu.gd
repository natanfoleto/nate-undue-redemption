class_name PauseMenu
extends CanvasLayer
## Pausa (09-interface): Continuar e Voltar ao menu principal. Mapa, Murais, Progresso e Opções chegam
## nas etapas deles.

@export_file("*.tscn") var main_menu: String

@onready var _panel: Control = %Panel
@onready var _resume: Button = %Resume
@onready var _to_menu: Button = %ToMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume.text = tr(&"PAUSE_RESUME")
	_to_menu.text = tr(&"PAUSE_MAIN_MENU")
	_resume.pressed.connect(_set_paused.bind(false))
	_to_menu.pressed.connect(_go_to_menu)
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_panel.visible = paused
	if paused:
		_resume.grab_focus()


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
