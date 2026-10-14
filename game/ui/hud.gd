class_name Hud
extends CanvasLayer
## HUD (09-interface): a barra de vida e os efeitos em Nate no alto, à esquerda; a barra fixa embaixo, no centro
## (Hotbar, com o aviso de item achado); as magias embaixo, à direita, com a recarga de cada uma e o sinal de
## combinação pronta. O centro da tela fica livre para os avisos dos golpes.

## Ícone de cada efeito de status, na ordem de StatusEffects.Effect.
@export var status_icons: Array[Texture2D] = []
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1
## Transparência do sinal de combinação quando ela ainda não está pronta.
@export var combo_dim := 0.0
## Quando a combinação fica pronta, o sinal pulsa: quanto ele cresce e quanto tempo leva, em segundos.
@export var combo_pulse_scale := 1.0
@export var combo_pulse_time := 0.0
## Quanto o sinal clareia no começo do pulso (acima de 1 clareia).
@export var combo_pulse_flash := Color.WHITE

var _player: Player
var _combo_was_ready := false
var _combo_tween: Tween

@onready var _health_bar: HealthBar = %HealthBar
@onready var _statuses: HBoxContainer = %Statuses
@onready var _spells: Control = %Spells
@onready var _slots: Array[Control] = [%Slot1, %Slot2]
@onready var _icons: Array[TextureRect] = [%Icon1, %Icon2]
@onready var _cooldowns: Array[ColorRect] = [%Cooldown1, %Cooldown2]
@onready var _keys: Array[TextureRect] = [%Key1, %Key2]
@onready var _combo: TextureRect = %Combo


func _ready() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Player
	if _player == null:
		return
	_player.health.changed.connect(_health_bar.show_value)
	_health_bar.show_value(_player.health.value, _player.health.max_value)
	_player.status.changed.connect(_show_statuses)
	_show_statuses()
	GameState.elements_changed.connect(_show_spells)
	InputManager.device_changed.connect(_on_device_changed)
	_show_spells()
	_combo_was_ready = _player.spells.combo_ready()


func _process(_delta: float) -> void:
	if _player == null or not _spells.visible:
		return
	for slot in 2:
		var id := GameState.equipped_element_id(slot)
		_cooldowns[slot].anchor_bottom = _player.spells.cooldown_share(id) if id != &"" else 0.0
	var combo_is_ready := _player.spells.combo_ready()
	_combo.modulate.a = 1.0 if combo_is_ready else combo_dim
	if combo_is_ready and not _combo_was_ready and _combo.visible:
		_pulse_combo()
	_combo_was_ready = combo_is_ready


# A combinação acabou de ficar pronta: o sinal cresce, clareia e volta.
func _pulse_combo() -> void:
	if _combo_tween:
		_combo_tween.kill()
	_combo.pivot_offset = _combo.size / 2.0
	_combo.scale = Vector2.ONE * combo_pulse_scale
	_combo.self_modulate = combo_pulse_flash
	_combo_tween = create_tween().set_parallel()
	_combo_tween.tween_property(_combo, ^"scale", Vector2.ONE, combo_pulse_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(_combo, ^"self_modulate", Color.WHITE, combo_pulse_time)


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
