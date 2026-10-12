@tool
class_name PoseData
extends Resource
## Pose-chave de uma animação: o giro e o deslocamento das partes que saem do repouso.
## A parte que a pose não cita fica em repouso.

enum Transition { SMOOTH, LINEAR }

## Momento da pose, em segundos.
@export var time := 0.0
## Como o movimento segue desta pose até a próxima: suave (devagar nas pontas) ou constante.
@export var transition := Transition.SMOOTH
## Giro de cada parte, em graus.
@export var rotations: Dictionary[StringName, Vector3] = {}
## Deslocamento de cada parte, em pixels.
@export var offsets: Dictionary[StringName, Vector3] = {}


## Mistura desta pose com outra: peso 0 é esta, 1 é a outra.
func blended(other: PoseData, weight: float) -> PoseData:
	var result := PoseData.new()
	result.rotations = _blend_values(rotations, other.rotations, weight)
	result.offsets = _blend_values(offsets, other.offsets, weight)
	return result


static func _blend_values(from: Dictionary[StringName, Vector3], to: Dictionary[StringName, Vector3], weight: float) -> Dictionary[StringName, Vector3]:
	var result: Dictionary[StringName, Vector3] = {}
	for part in from:
		var target: Vector3 = to.get(part, Vector3.ZERO)
		result[part] = from[part].lerp(target, weight)
	for part in to:
		if not from.has(part):
			result[part] = Vector3.ZERO.lerp(to[part], weight)
	return result
