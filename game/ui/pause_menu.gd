class_name PauseMenu
extends CanvasLayer
## Pausa (09-interface): Continuar, Murais e Voltar ao menu principal. A galeria mostra os murais já vistos, para
## ver de novo, e quantos dos 7 Nate já achou. Mapa, Progresso e Opções chegam nas etapas deles.

@export_file("*.tscn") var main_menu: String
## Quantas vezes as miniaturas dos murais na galeria são ampliadas.
@export var thumbnail_scale := 1

@onready var _panel: Control = %Panel
@onready var _list: Control = %List
@onready var _resume: Button = %Resume
@onready var _murals: Button = %Murals
@onready var _to_menu: Button = %ToMenu
@onready var _gallery: Control = %Gallery
@onready var _gallery_title: Label = %GalleryTitle
@onready var _gallery_grid: GridContainer = %GalleryGrid
@onready var _gallery_back: Button = %GalleryBack


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume.text = tr(&"PAUSE_RESUME")
	_murals.text = tr(&"PAUSE_MURALS")
	_to_menu.text = tr(&"PAUSE_MAIN_MENU")
	_gallery_back.text = tr(&"PAUSE_BACK")
	_resume.pressed.connect(_set_paused.bind(false))
	_murals.pressed.connect(_show_gallery)
	_to_menu.pressed.connect(_go_to_menu)
	_gallery_back.pressed.connect(_show_list)
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause") and not (_gallery.visible and event.is_action_pressed(&"ui_cancel")):
		return
	# Outra tela já parou o jogo (inventário, santuário, pergaminho): ela cuida do botão.
	if get_tree().paused and not _panel.visible:
		return
	get_viewport().set_input_as_handled()
	if _gallery.visible:
		_show_list()
		return
	_set_paused(not _panel.visible)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_panel.visible = paused
	if paused:
		_show_list()


func _show_list() -> void:
	_gallery.visible = false
	_list.visible = true
	_resume.grab_focus()


# A galeria (09-interface): os murais vistos abrem grandes de novo; os que faltam ficam escuros.
func _show_gallery() -> void:
	for child in _gallery_grid.get_children():
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
		_gallery_grid.add_child(button)
	_gallery_title.text = tr(&"PAUSE_MURALS_FOUND") % [found, Mural.COUNT]
	_list.visible = false
	_gallery.visible = true
	_gallery_back.grab_focus()


func _open_mural(id: int) -> void:
	var view := (load(Mural.VIEW_SCENE) as PackedScene).instantiate() as MuralView
	add_child(view)
	await view.show_image(Mural.image(id))
	_gallery_back.grab_focus()


func _go_to_menu() -> void:
	SaveSystem.save()
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
