class_name ItemFound
extends Node3D
## Sinal de achar item (05-itens, 10-arte-audio): partículas e o nome do item subindo e sumindo.
## A cena configura o texto e as partículas.

const SCENE_PATH := "res://world/objects/item_found.tscn"

## Quanto o nome sobe, em blocos, e em quanto tempo, em segundos.
@export var rise := 0.0
@export var duration := 0.0

@onready var _label: Label3D = $Label3D
@onready var _sparkles: CPUParticles3D = $Sparkles


## Mostra o sinal sobre [param where], com o nome do item.
static func show_found(where: Node3D, item_id: StringName) -> void:
	# Carregada aqui: a cena usa este mesmo script.
	var found := (load(SCENE_PATH) as PackedScene).instantiate() as ItemFound
	where.get_parent().add_child(found)
	found.global_position = where.global_position
	var item: Resource = load(GameState.ITEMS_FOLDER + item_id + ".tres")
	found._label.text = found.tr(item.get(&"name_key")) if item else ""
	found._sparkles.emitting = true
	var tween := found.create_tween().set_parallel()
	tween.tween_property(found._label, ^"position:y", found._label.position.y + found.rise, found.duration)
	tween.tween_property(found._label, ^"modulate:a", 0.0, found.duration).set_delay(found.duration / 2.0)
	tween.chain().tween_callback(found.queue_free)
