class_name SummaryScreen
extends CanvasLayer
## Resumo da partida (09-interface): depois dos créditos, o tempo de jogo, as mortes e os segredos achados (murais,
## melhorias, pergaminhos e equipamento). Qualquer botão segue para o pós-jogo, depois de um tempo.

signal finished

@export var data: SummaryData
## Tempo da tela clareando e escurecendo, e o tempo até aceitar um botão, em segundos.
@export var fade_time := 0.0
@export var wait_time := 0.0
## Tamanho das letras das linhas, em pixels.
@export var row_font_size := 0

var _can_leave := false
var _leaving := false

@onready var _title: Label = %Title
@onready var _rows: GridContainer = %Rows
@onready var _continue: Label = %Continue
@onready var _fade: ColorRect = %Fade


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_title.text = tr(&"SUMMARY_TITLE")
	_continue.text = tr(&"SUMMARY_CONTINUE")
	var save := SaveSystem.data
	var items: Array = save.get(SaveSystem.ITEMS, [])
	var equipment := data.equipment.filter(func(id: StringName) -> bool: return String(id) in items).size()
	_add_row(&"SUMMARY_TIME", time_text(float(save.get("play_time", 0.0))))
	_add_row(&"SUMMARY_DEATHS", str(int(save.get("deaths", 0))))
	_add_row(&"SUMMARY_MURALS", tr(&"SUMMARY_OF") % [(save.get(SaveSystem.MURALS, []) as Array).size(), Mural.COUNT])
	_add_row(&"SUMMARY_UPGRADES", tr(&"SUMMARY_OF") % [(save.get(SaveSystem.UPGRADES, []) as Array).size(), data.upgrades_total])
	_add_row(&"SUMMARY_SCROLLS", tr(&"SUMMARY_OF") % [(save.get(SaveSystem.ELEMENTS, []) as Array).size(), data.scrolls_total])
	_add_row(&"SUMMARY_EQUIPMENT", tr(&"SUMMARY_OF") % [equipment, data.equipment.size()])
	_continue.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_fade, ^"color:a", 0.0, fade_time)
	tween.tween_interval(wait_time)
	tween.tween_callback(func() -> void: _can_leave = true)
	tween.tween_property(_continue, ^"modulate:a", 1.0, fade_time)


## O tempo de jogo como horas, minutos e segundos (1:05:09), ou só minutos e segundos (5:09).
static func time_text(seconds: float) -> String:
	var total := floori(seconds)
	var hours := floori(total / 3600.0)
	var minutes := floori(total / 60.0) % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, total % 60]
	return "%d:%02d" % [minutes, total % 60]


func _add_row(key: StringName, value: String) -> void:
	for text in [tr(key), value]:
		var label := Label.new()
		label.text = text
		label.add_theme_font_size_override(&"font_size", row_font_size)
		_rows.add_child(label)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_leave or _leaving or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_leave()


func _leave() -> void:
	_leaving = true
	AudioManager.play(&"ui_confirm")
	var tween := create_tween()
	tween.tween_property(_fade, ^"color:a", 1.0, fade_time)
	await tween.finished
	finished.emit()
