class_name Hud
extends CanvasLayer
## HUD (09-interface): corações, frasco e efeitos em Nate no alto, à esquerda; o equipamento embaixo, à esquerda,
## com o aviso de cada item achado; as magias embaixo, à direita, com a recarga de cada uma e o sinal de combinação
## pronta. O centro da tela fica livre para os avisos dos golpes.

@export var heart_full: Texture2D
@export var heart_empty: Texture2D
## Ícone de cada efeito de status, na ordem de StatusEffects.Effect.
@export var status_icons: Array[Texture2D] = []
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1
## Transparência do sinal de combinação quando ela ainda não está pronta.
@export var combo_dim := 0.0
## Molduras do equipamento (10-arte-audio): marajoara em verde-jade; comum em cinza.
@export var marajoara_color := Color.WHITE
@export var common_color := Color.WHITE
## Ícone do frasco, para o aviso de quando Nate o ganha.
@export var flask_icon: Texture2D
## Tempo do aviso de item achado na tela e tempo dele sumindo, em segundos.
@export var toast_time := 0.0
@export var toast_fade_time := 0.0

var _player: Player
var _toast_tween: Tween

@onready var _hearts: HBoxContainer = %Hearts
@onready var _flask: Control = %Flask
@onready var _flask_charges: Label = %FlaskCharges
@onready var _statuses: HBoxContainer = %Statuses
@onready var _spells: Control = %Spells
@onready var _slots: Array[Control] = [%Slot1, %Slot2]
@onready var _icons: Array[TextureRect] = [%Icon1, %Icon2]
@onready var _cooldowns: Array[ColorRect] = [%Cooldown1, %Cooldown2]
@onready var _keys: Array[TextureRect] = [%Key1, %Key2]
@onready var _combo: TextureRect = %Combo
@onready var _equipment: Array[TextureRect] = [%Melee, %Ranged, %Armor]
@onready var _toast: Control = %Toast
@onready var _toast_icon: TextureRect = %ToastIcon
@onready var _toast_label: Label = %ToastLabel


func _ready() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Player
	if _player == null:
		return
	_player.health.changed.connect(_show_hearts)
	_show_hearts(_player.health.value, _player.health.max_value)
	_player.flask.changed.connect(_show_flask)
	_show_flask(_player.flask.charges, _player.flask.max_charges)
	_player.status.changed.connect(_show_statuses)
	_show_statuses()
	GameState.elements_changed.connect(_show_spells)
	InputManager.device_changed.connect(_on_device_changed)
	_show_spells()
	GameState.equipment_changed.connect(_show_equipment)
	Events.item_picked.connect(_on_item_picked)
	_show_equipment()
	_toast.visible = false


func _process(_delta: float) -> void:
	if _player == null or not _spells.visible:
		return
	for slot in 2:
		var id := GameState.equipped_element_id(slot)
		_cooldowns[slot].anchor_bottom = _player.spells.cooldown_share(id) if id != &"" else 0.0
	_combo.modulate.a = 1.0 if _player.spells.combo_ready() else combo_dim


func _show_hearts(value: int, max_value: int) -> void:
	for heart in _hearts.get_children():
		heart.free()
	for i in max_value:
		_hearts.add_child(_icon(heart_full if i < value else heart_empty))


# O frasco aparece quando Nate o ganha, no primeiro santuário (04-player).
func _show_flask(charges: int, _max_charges: int) -> void:
	_flask.visible = GameState.has_flask()
	_flask_charges.text = str(charges)


func _show_statuses() -> void:
	for icon in _statuses.get_children():
		icon.free()
	for effect in _player.status.active():
		_statuses.add_child(_icon(status_icons[effect]))


# Os 2 elementos equipados; a combinação aparece com os dois escolhidos e quando ela existe (05-itens).
func _show_spells() -> void:
	_spells.visible = not GameState.learned_elements().is_empty()
	for slot in 2:
		var element := GameState.equipped_element(slot)
		_slots[slot].modulate.a = 1.0 if element else combo_dim
		_icons[slot].texture = element.icon if element else null
	var first := GameState.equipped_element_id(0)
	var second := GameState.equipped_element_id(1)
	var combos := _player.spells.combos
	var key := ComboTable.key(first, second)
	_combo.visible = first != &"" and second != &"" and combos.icons.has(key)
	_combo.texture = combos.icons.get(key)
	_show_keys()


# O que Nate tem nas mãos e no corpo: a arma de perto, a de longe e a armadura.
func _show_equipment() -> void:
	var slots := [GameState.MELEE, GameState.RANGED, GameState.ARMOR]
	for i in slots.size():
		var item := GameState.equipped(slots[i]) as ItemData
		_equipment[i].texture = item.icon if item else null
		var frame := _equipment[i].get_parent() as Control
		frame.self_modulate = (marajoara_color if item.marajoara else common_color) if item else Color(common_color, combo_dim)


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


# O ícone e o nome de um item achado: equipamento, melhoria (o tipo vem no começo do identificador), elemento ou o
# frasco.
func _find_item(item_id: StringName) -> Array:
	if item_id == GameState.FLASK:
		return [flask_icon, &"ITEM_FLASK"]
	var paths := [GameState.ITEMS_FOLDER + item_id + ".tres", GameState.ELEMENTS_FOLDER + item_id + ".tres",
		ItemPickup.UPGRADES_FOLDER + String(item_id).get_slice("_", 0) + ".tres"]
	for path: String in paths:
		if ResourceLoader.exists(path):
			var item: Resource = load(path)
			return [item.get(&"icon"), item.get(&"name_key")]
	return []


func _on_device_changed(_device: int) -> void:
	_show_keys()


func _show_keys() -> void:
	for slot in 2:
		var icons := InputManager.icons_for([&"spell_1" if slot == 0 else &"spell_2"])
		_keys[slot].texture = icons[0] if not icons.is_empty() else null


func _icon(texture: Texture2D) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = texture.get_size() * icon_scale
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	return icon
