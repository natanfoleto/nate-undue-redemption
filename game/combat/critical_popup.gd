class_name CriticalPopup
extends Node3D
## Sinal do crítico (03-regras, 10-arte-audio): número amarelo grande e faíscas amarelas.
## A cena configura o texto e as faíscas; aqui o número sobe e some.

## Quanto o número sobe, em blocos, e em quanto tempo, em segundos.
@export var rise := 0.0
@export var duration := 0.0

@onready var _label: Label3D = $Label3D
@onready var _sparks: CPUParticles3D = $Sparks


## Mostra o dano do crítico em [param where], no mundo.
static func spawn(scene: PackedScene, parent: Node, where: Vector3, points: int) -> void:
	var popup := scene.instantiate() as CriticalPopup
	parent.add_child(popup)
	popup.global_position = where
	popup._label.text = str(points)
	popup._sparks.emitting = true
	var tween := popup.create_tween().set_parallel()
	tween.tween_property(popup._label, ^"position:y", popup.rise, popup.duration)
	tween.tween_property(popup._label, ^"modulate:a", 0.0, popup.duration)
	tween.chain().tween_callback(popup.queue_free)
