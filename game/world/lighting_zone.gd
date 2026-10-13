class_name LightingZone
extends Node3D
## Luz por área (10-arte-audio): dentro da zona (embaixo da terra) o sol some e o ambiente escurece, e a luz
## vem dos lampiões; fora dela, a luz do dia da superfície. A troca é suave.

@export var sun: DirectionalLight3D
@export var world: WorldEnvironment
## Retângulo da zona no chão, centrado no nó, em blocos.
@export var area_size := Vector2.ZERO
## Força do sol e da luz ambiente dentro da zona.
@export var inside_sun_energy := 0.0
@export var inside_ambient_energy := 0.0
## Tempo da troca de luz, em segundos.
@export var change_time := 0.0

var _outside_sun := 0.0
var _outside_ambient := 0.0


func _ready() -> void:
	_outside_sun = sun.light_energy
	_outside_ambient = world.environment.ambient_light_energy
	# Começa já com a luz certa, depois de a área pôr Nate no ponto de retorno, que pode ser dentro da zona.
	_snap.call_deferred()


func _snap() -> void:
	_apply(1.0 if _player_inside() else 0.0)


func _process(delta: float) -> void:
	var target := 1.0 if _player_inside() else 0.0
	var current := inverse_lerp(_outside_sun, inside_sun_energy, sun.light_energy) if _outside_sun != inside_sun_energy else target
	var step := delta / change_time if change_time > 0.0 else 1.0
	_apply(move_toward(current, target, step))


# 0 é a luz de fora; 1, a de dentro.
func _apply(weight: float) -> void:
	sun.light_energy = lerpf(_outside_sun, inside_sun_energy, weight)
	sun.visible = sun.light_energy > 0.0
	world.environment.ambient_light_energy = lerpf(_outside_ambient, inside_ambient_energy, weight)


func _player_inside() -> bool:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	if player == null:
		return false
	var offset := player.global_position - global_position
	return absf(offset.x) <= area_size.x / 2.0 and absf(offset.z) <= area_size.y / 2.0
