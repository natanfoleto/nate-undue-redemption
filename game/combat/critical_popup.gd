class_name CriticalPopup
extends Node3D
## Sinal do crítico (03-regras, 10-arte-audio): número amarelo grande e faíscas amarelas. Serve também ao sinal de
## imune: a palavra "imune", em cinza, sem faíscas (immune_popup.tscn).
## A cena configura o texto e as faíscas; aqui o número sobe e some.

## Quanto o número sobe, em blocos, e em quanto tempo, em segundos.
@export var rise := 0.0
@export var duration := 0.0
## Chave do texto fixo na tabela de tradução (o imune); vazia, mostra o dano.
@export var text_key: StringName

@onready var _label: Label3D = $Label3D
@onready var _sparks: CPUParticles3D = get_node_or_null(^"Sparks")


## Mostra o dano do crítico (ou o texto fixo da cena) em [param where], no mundo.
static func spawn(scene: PackedScene, parent: Node, where: Vector3, points: int) -> void:
	var popup := scene.instantiate() as CriticalPopup
	parent.add_child(popup)
	popup.global_position = where
	popup._label.text = popup.tr(popup.text_key) if popup.text_key != &"" else str(points)
	if popup._sparks:
		popup._sparks.emitting = true
	var tween := popup.create_tween().set_parallel()
	tween.tween_property(popup._label, ^"position:y", popup.rise, popup.duration)
	tween.tween_property(popup._label, ^"modulate:a", 0.0, popup.duration)
	tween.chain().tween_callback(popup.queue_free)
