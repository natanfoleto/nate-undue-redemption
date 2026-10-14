class_name MuralGallery
extends CanvasLayer
## Galeria dos murais (09-interface): abre com o botão dos murais (G; no controle, o direcional para cima) e para o
## jogo. Mostra os murais já vistos, para ver de novo em tamanho grande, e quantos dos 7 Nate já achou; os que faltam
## ficam escuros.

## Quantas vezes as miniaturas dos murais são ampliadas.
@export var thumbnail_scale := 1

@onready var _panel: Control = %Panel
@onready var _title: Label = %Title
@onready var _grid: GridContainer = %Grid
@onready var _back: Button = %Back


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_back.text = tr(&"PAUSE_BACK")
	_back.pressed.connect(_close)


func _unhandled_input(event: InputEvent) -> void:
	if _panel.visible:
		# No controle, o botão dos murais é o direcional para cima, que também anda pelas miniaturas: lá, fecha só com
		# Voltar ou com a pausa.
		var closes := event.is_action_pressed(&"murals") and not event.is_action(&"ui_up")
		if closes or event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
			get_viewport().set_input_as_handled()
			_close()
		return
	if event.is_action_pressed(&"murals") and not get_tree().paused:
		var player := get_tree().get_first_node_in_group(&"player") as Player
		if player and not player.is_dead() and not player.is_cinematic():
			get_viewport().set_input_as_handled()
			_open()


func _open() -> void:
	get_tree().paused = true
	AudioManager.play(&"ui_open")
	for child in _grid.get_children():
		child.free()
	var found := 0
	for id in range(1, Mural.COUNT + 1):
		var button := Button.new()
		button.custom_minimum_size = Mural.image(id).get_size() * thumbnail_scale
		button.expand_icon = true
		if Mural.seen(id):
			found += 1
			button.icon = Mural.image(id)
			button.pressed.connect(_open_mural.bind(id))
		else:
			button.disabled = true
		_grid.add_child(button)
	_title.text = tr(&"PAUSE_MURALS_FOUND") % [found, Mural.COUNT]
	_panel.visible = true
	_back.grab_focus()


func _close() -> void:
	AudioManager.play(&"ui_close")
	_panel.visible = false
	get_tree().paused = false


func _open_mural(id: int) -> void:
	var view := (load(Mural.VIEW_SCENE) as PackedScene).instantiate() as MuralView
	add_child(view)
	await view.show_image(Mural.image(id))
	_back.grab_focus()
