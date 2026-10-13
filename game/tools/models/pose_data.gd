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


## Mistura desta pose com outra: peso 0 é esta, 1 é a outra. Com [param shortest], cada giro
## segue pelo lado mais curto: sair de um giro de 360° não desvira a parte.
func blended(other: PoseData, weight: float, shortest := false) -> PoseData:
	var result := PoseData.new()
	result.rotations = _blend_values(rotations, other.rotations, weight, shortest)
	result.offsets = _blend_values(offsets, other.offsets, weight, false)
	return result


## Esta pose com outra por cima: só as partes que a outra cita mudam, na medida do peso (0 a 1).
## É como os braços puxam o tiro enquanto as pernas andam.
func overlaid(other: PoseData, weight: float) -> PoseData:
	var result := PoseData.new()
	result.rotations = rotations.duplicate()
	result.offsets = offsets.duplicate()
	for part in other.rotations:
		var start: Vector3 = rotations.get(part, Vector3.ZERO)
		var change: Vector3 = other.rotations[part] - start
		change = Vector3(wrapf(change.x, -180.0, 180.0), wrapf(change.y, -180.0, 180.0), wrapf(change.z, -180.0, 180.0))
		result.rotations[part] = start + change * weight
	for part in other.offsets:
		var start: Vector3 = offsets.get(part, Vector3.ZERO)
		result.offsets[part] = start.lerp(other.offsets[part], weight)
	return result


static func _blend_values(from: Dictionary[StringName, Vector3], to: Dictionary[StringName, Vector3], weight: float, shortest: bool) -> Dictionary[StringName, Vector3]:
	var result: Dictionary[StringName, Vector3] = {}
	for part in from.keys() + to.keys():
		if result.has(part):
			continue
		var start: Vector3 = from.get(part, Vector3.ZERO)
		var change: Vector3 = to.get(part, Vector3.ZERO) - start
		if shortest:
			change = Vector3(wrapf(change.x, -180.0, 180.0), wrapf(change.y, -180.0, 180.0), wrapf(change.z, -180.0, 180.0))
		result[part] = start + change * weight
	return result
