class_name ButtonHint
extends HBoxContainer
## Uma dica de controle (09-interface): os ícones dos botões e o nome da ação. Some quando a ação é usada.
## Os ícones trocam sozinhos quando o jogador muda de dispositivo.

## Ações da dica, na ordem dos ícones; usar qualquer uma delas tira a dica.
@export var actions: Array[StringName] = []
## Chave do nome da ação na tabela de tradução.
@export var text_key: StringName
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1

@onready var _icons: HBoxContainer = $Icons
@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = tr(text_key)
	InputManager.device_changed.connect(_on_device_changed)
	_show_icons()


func _unhandled_input(event: InputEvent) -> void:
	for action in actions:
		if event.is_action_pressed(action):
			queue_free()
			return


func _on_device_changed(_device: int) -> void:
	_show_icons()


func _show_icons() -> void:
	for icon in _icons.get_children():
		icon.free()
	for texture in InputManager.icons_for(actions):
		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = texture.get_size() * icon_scale
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_icons.add_child(icon)
