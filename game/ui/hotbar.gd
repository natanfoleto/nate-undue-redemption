class_name Hotbar
extends CanvasLayer
## Barra fixa (09-interface): 5 espaços embaixo, no centro da tela, com as armas e a poção. O espaço com a moldura
## dourada é o item na mão de Nate; os números (o direcional, no controle) trocam de espaço. Com o inventário aberto,
## ela some: o inventário tem a barra dele. Em cima dela aparecem o nome do item que Nate pegou na mão e o aviso de
## item achado.

@export var look: CellLook
## Tempo do nome do item da mão na tela e tempo dele sumindo, em segundos.
@export var name_time := 0.0
@export var name_fade_time := 0.0
## Tempo do aviso de item achado na tela e tempo dele sumindo, em segundos.
@export var toast_time := 0.0
@export var toast_fade_time := 0.0
## Tempo da barra sumindo quando Nate morre e voltando quando ele reaparece, em segundos.
@export var hide_time := 0.0

var cells: Array[ItemCell] = []

var _player: Player
var _name_tween: Tween
var _toast_tween: Tween
var _hide_tween: Tween

@onready var _root: Control = %Root
@onready var _row: HBoxContainer = %Row
@onready var _hand_name: Label = %HandName
@onready var _toast: Control = %Toast
@onready var _toast_icon: TextureRect = %ToastIcon
@onready var _toast_label: Label = %ToastLabel
@onready var _arrows: Array[Label] = [%Previous, %Next]


func _ready() -> void:
	add_to_group(&"hotbar")
	for i in GameState.HOTBAR_SIZE:
		var cell := ItemCell.new()
		cell.look = look
		cell.place = GameState.HOTBAR
		cell.index = i
		cell.number = i + 1
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.focus_mode = Control.FOCUS_NONE
		_row.add_child(cell)
		cells.append(cell)
	_row.move_child(_arrows[1], -1)
	_hand_name.modulate.a = 0.0
	_toast.visible = false
	GameState.inventory_changed.connect(refresh)
	GameState.hand_changed.connect(_on_hand_changed)
	Events.item_picked.connect(_on_item_picked)
	Events.player_died.connect(_fade.bind(0.0))
	Events.player_respawned.connect(_fade.bind(1.0))
	InputManager.device_changed.connect(_on_device_changed)
	_on_device_changed(InputManager.device)
	_player = get_tree().get_first_node_in_group(&"player") as Player
	if _player:
		_player.flask.changed.connect(func(_charges: int, _max_charges: int) -> void: refresh())
	refresh()


func refresh() -> void:
	show_slots(cells, _player)


## Mostra a barra fixa nos espaços dados (a do HUD e a do inventário): o item, a moldura da mão e as cargas da poção.
static func show_slots(slots: Array[ItemCell], player: Player) -> void:
	for cell in slots:
		cell.item = GameState.item_at(GameState.HOTBAR, cell.index)
		cell.in_hand = cell.index == GameState.hand()
		cell.count_text = str(player.flask.charges) if cell.item is PotionData and player else ""


# O nome do item que Nate pegou na mão aparece um instante em cima da barra.
func _on_hand_changed() -> void:
	refresh()
	var held := GameState.hand_item()
	if _name_tween:
		_name_tween.kill()
	_hand_name.text = tr(held.name_key) if held else ""
	_hand_name.modulate.a = 1.0
	_name_tween = create_tween()
	_name_tween.tween_interval(name_time)
	_name_tween.tween_property(_hand_name, ^"modulate:a", 0.0, name_fade_time)


# Aviso de item achado: o ícone e o nome, por um tempo (05-itens).
func _on_item_picked(item_id: StringName) -> void:
	var found := _find_item(item_id)
	if found.is_empty():
		return
	_toast_icon.texture = found[0]
	_toast_label.text = tr(found[1])
	_toast.visible = true
	_toast.modulate.a = 1.0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(toast_time)
	_toast_tween.tween_property(_toast, ^"modulate:a", 0.0, toast_fade_time)
	_toast_tween.tween_callback(_toast.hide)


# O ícone e o nome de um item achado: item (as armas, a armadura, a poção), melhoria (o tipo vem no começo do
# identificador) ou elemento.
func _find_item(item_id: StringName) -> Array:
	var paths := [GameState.ITEMS_FOLDER + item_id + ".tres", GameState.ELEMENTS_FOLDER + item_id + ".tres",
		ItemPickup.UPGRADES_FOLDER + String(item_id).get_slice("_", 0) + ".tres"]
	for path: String in paths:
		if ResourceLoader.exists(path):
			var item: Resource = load(path)
			return [item.get(&"icon"), item.get(&"name_key")]
	return []


func _fade(alpha: float) -> void:
	if _hide_tween:
		_hide_tween.kill()
	_hide_tween = create_tween()
	_hide_tween.tween_property(_root, ^"modulate:a", alpha, hide_time)


# No controle, as setas mostram que o direcional passa pelos espaços; no teclado, os números bastam.
func _on_device_changed(_device: int) -> void:
	for arrow in _arrows:
		arrow.visible = InputManager.is_gamepad()
