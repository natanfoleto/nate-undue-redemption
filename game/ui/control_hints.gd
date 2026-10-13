class_name ControlHints
extends VBoxContainer
## Lista de dicas de controle presa perto de Nate na tela (09-interface). Fica escondida quando não há dica.

## Quem as dicas acompanham.
@export var target: Node3D
## Altura do ponto de referência acima do alvo, em blocos; as dicas ficam centradas logo acima dele.
@export var height := 0.0


## Põe uma dica nova na lista.
func add_hint(hint: ButtonHint) -> void:
	add_child(hint)


func _process(_delta: float) -> void:
	visible = get_child_count() > 0
	if not visible:
		return
	var camera := get_viewport().get_camera_3d()
	if target == null or camera == null:
		return
	reset_size() # Encolhe quando uma dica sai.
	var anchor := camera.unproject_position(target.global_position + Vector3.UP * height)
	position = anchor - Vector2(size.x / 2.0, size.y)
