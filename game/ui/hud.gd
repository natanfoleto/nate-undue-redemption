class_name Hud
extends CanvasLayer
## HUD (09-interface): os corações de Nate no alto, à esquerda. O centro da tela fica livre para os avisos.

@export var heart_full: Texture2D
@export var heart_empty: Texture2D
## Quantas vezes os ícones de 16 px são ampliados.
@export var icon_scale := 1

@onready var _hearts: HBoxContainer = $Hearts


func _ready() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		player.health.changed.connect(_show_hearts)
		_show_hearts(player.health.value, player.health.max_value)


func _show_hearts(value: int, max_value: int) -> void:
	for heart in _hearts.get_children():
		heart.free()
	for i in max_value:
		var heart := TextureRect.new()
		heart.texture = heart_full if i < value else heart_empty
		heart.custom_minimum_size = heart.texture.get_size() * icon_scale
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_hearts.add_child(heart)
