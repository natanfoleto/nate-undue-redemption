class_name RespawnPoint
extends Marker3D
## Ponto de retorno (02-core-loop): antes do primeiro santuário, o início do prólogo e a entrada da Mina.
## Quando Nate passa por ele, vira o lugar para onde ele volta ao morrer e ao abrir o jogo de novo.

## Identificador único no mapa.
@export var id: StringName
## Distância em que Nate ativa o ponto ao passar, em blocos.
@export var radius := 0.0


func _ready() -> void:
	add_to_group(&"respawn_points")


func _physics_process(_delta: float) -> void:
	if GameState.respawn_point() == id:
		return
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.is_dead():
		return
	var offset := player.global_position - global_position
	if Vector2(offset.x, offset.z).length() <= radius:
		GameState.set_respawn_point(id)
		player.set_spawn(global_position, Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))
