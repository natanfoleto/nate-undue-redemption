class_name PauseMenu
extends CanvasLayer
## Pausa (09-interface): Continuar, Configurações e Voltar ao menu principal. As configurações mudam o volume da
## música e o dos efeitos sonoros, guardados nas opções. Os murais têm a própria galeria (MuralGallery); Mapa e
## Progresso chegam nas etapas deles.

@export_file("*.tscn") var main_menu: String

@onready var _panel: Control = %Panel
@onready var _list: Control = %List
@onready var _resume: Button = %Resume
@onready var _to_menu: Button = %ToMenu
@onready var _settings_button: Button = %SettingsButton
@onready var _settings: Control = %Settings
@onready var _settings_title: Label = %SettingsTitle
@onready var _music_label: Label = %MusicLabel
@onready var _music_slider: HSlider = %MusicSlider
@onready var _effects_label: Label = %EffectsLabel
@onready var _effects_slider: HSlider = %EffectsSlider
@onready var _settings_back: Button = %SettingsBack


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume.text = tr(&"PAUSE_RESUME")
	_to_menu.text = tr(&"PAUSE_MAIN_MENU")
	_settings_button.text = tr(&"PAUSE_SETTINGS")
	_settings_title.text = tr(&"PAUSE_SETTINGS")
	_music_label.text = tr(&"SETTINGS_MUSIC")
	_effects_label.text = tr(&"SETTINGS_EFFECTS")
	_settings_back.text = tr(&"PAUSE_BACK")
	_resume.pressed.connect(_set_paused.bind(false))
	_settings_button.pressed.connect(_show_settings)
	_to_menu.pressed.connect(_go_to_menu)
	_settings_back.pressed.connect(_show_list)
	_music_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_music_volume(value / _music_slider.max_value))
	_effects_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_effects_volume(value / _effects_slider.max_value))
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	var inside := _settings.visible
	if not event.is_action_pressed(&"pause") and not (inside and event.is_action_pressed(&"ui_cancel")):
		return
	# Outra tela já parou o jogo (inventário, santuário, pergaminho): ela cuida do botão.
	if get_tree().paused and not _panel.visible:
		return
	get_viewport().set_input_as_handled()
	if inside:
		AudioManager.play(&"ui_back")
		_show_list()
		return
	_set_paused(not _panel.visible)


func _set_paused(paused: bool) -> void:
	AudioManager.play(&"ui_open" if paused else &"ui_close")
	get_tree().paused = paused
	_panel.visible = paused
	if paused:
		_show_list()


func _show_list() -> void:
	_settings.visible = false
	_list.visible = true
	_resume.grab_focus()


func _show_settings() -> void:
	_music_slider.set_value_no_signal(AudioManager.music_volume * _music_slider.max_value)
	_effects_slider.set_value_no_signal(AudioManager.effects_volume * _effects_slider.max_value)
	_list.visible = false
	_settings.visible = true
	_music_slider.grab_focus()


func _go_to_menu() -> void:
	SaveSystem.save()
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
