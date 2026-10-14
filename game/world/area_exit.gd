class_name AreaExit
extends Node3D
## Saída de uma área (12-tecnico): quando Nate entra no retângulo, a próxima área carrega e ele aparece no ponto de
## chegada dela.

## Cena da próxima área e o ponto onde Nate chega nela.
@export_file("*.tscn") var next_area: String
@export var arrival: StringName
## Retângulo no chão, centrado no nó, em blocos.
@export var area_size := Vector2.ZERO
## A saída só vale com o Selo no muiraquitã (a das Ruínas, para a Grande Prisão).
@export var needs_seal := false

var _done := false


func _physics_process(_delta: float) -> void:
	if _done:
		return
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.is_dead():
		return
	var offset := player.global_position - global_position
	if absf(offset.x) > area_size.x / 2.0 or absf(offset.z) > area_size.y / 2.0:
		return
	if needs_seal and not GameState.has_seal():
		return
	_done = true
	player.set_cinematic(true)
	GameState.change_area(next_area, arrival)
