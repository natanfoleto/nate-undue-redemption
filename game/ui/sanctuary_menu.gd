class_name SanctuaryMenu
extends CanvasLayer
## Menu do santuário (09-interface): Descansar e Viajar, que mostra a lista dos santuários já visitados.
## Com ele aberto, o jogo fica parado.

## Fecha o menu: [param choice] é o santuário de destino da viagem, ou nulo para ficar.
signal closed(choice: SanctuaryData)

var _sanctuary: Sanctuary
var _resting := false

@onready var _title: Label = %Title
@onready var _rest: Button = %Rest
@onready var _travel: Button = %Travel
@onready var _leave: Button = %Leave
@onready var _main: VBoxContainer = %Main
@onready var _places: VBoxContainer = %Places


## Tamanho do texto dos botões, em pixels da tela.
@export var font_size := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for button in [_rest, _travel, _leave]:
		button.add_theme_font_size_override(&"font_size", font_size)
	_rest.text = tr(&"SANCTUARY_REST")
	_travel.text = tr(&"SANCTUARY_TRAVEL")
	_leave.text = tr(&"SANCTUARY_LEAVE")
	_rest.pressed.connect(_on_rest)
	_travel.pressed.connect(_show_places)
	_leave.pressed.connect(_close.bind(null))


func open(sanctuary: Sanctuary) -> void:
	_sanctuary = sanctuary
	_title.text = tr(sanctuary.data.name_key)
	_travel.disabled = _destinations().is_empty()
	get_tree().paused = true
	_show_main()


func _unhandled_input(event: InputEvent) -> void:
	if _resting:
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if _places.visible:
			_show_main()
		else:
			_close(null)


# Durante o descanso, nada fecha o menu: a tela escurece e clareia antes de ele voltar.
func _on_rest() -> void:
	_resting = true
	for button in [_rest, _travel, _leave]:
		button.disabled = true
	await _sanctuary.rest()
	_resting = false
	_rest.disabled = false
	_leave.disabled = false
	_travel.disabled = _destinations().is_empty()
	_rest.grab_focus()


func _show_main() -> void:
	_places.visible = false
	_main.visible = true
	_rest.grab_focus()


# A lista dos santuários já visitados, menos este (02-core-loop).
func _show_places() -> void:
	for child in _places.get_children():
		child.free()
	for place in _destinations():
		var button := Button.new()
		button.text = tr(place.name_key)
		button.add_theme_font_size_override(&"font_size", font_size)
		button.pressed.connect(_close.bind(place))
		_places.add_child(button)
	var back := Button.new()
	back.text = tr(&"SANCTUARY_BACK")
	back.add_theme_font_size_override(&"font_size", font_size)
	back.pressed.connect(_show_main)
	_places.add_child(back)
	_main.visible = false
	_places.visible = true
	(_places.get_child(0) as Button).grab_focus.call_deferred()


func _destinations() -> Array[SanctuaryData]:
	var list: Array[SanctuaryData] = []
	for place in GameState.visited_sanctuaries():
		if place.id() != _sanctuary.data.id():
			list.append(place)
	return list


func _close(choice: SanctuaryData) -> void:
	get_tree().paused = false
	closed.emit(choice)
	queue_free()
