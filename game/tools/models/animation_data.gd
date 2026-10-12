@tool
class_name AnimationData
extends Resource
## Animação por poses-chave no tempo (12-tecnico). Tocada pelo ModelAnimator.

## Duração, em segundos.
@export var length := 1.0
## Volta ao começo ao terminar; a última pose segue para a primeira.
@export var loop := false
## Tempo, em segundos, para sair da animação anterior e entrar nesta.
@export var blend_time := 0.0
## Poses em ordem de tempo.
@export var poses: Array[PoseData] = []


## Pose no tempo dado, em segundos desde o começo da animação.
func sample(time: float) -> PoseData:
	# Sem poses, ou com uma vaga ainda vazia no inspetor: fica em repouso.
	if poses.is_empty() or poses.has(null):
		return PoseData.new()
	var t := fposmod(time, length) if loop and length > 0.0 else clampf(time, 0.0, length)
	var index := poses.size() - 1
	for i in poses.size():
		if poses[i].time > t:
			index = i - 1
			break
	if index < 0:
		if not loop:
			return poses[0]
		index = poses.size() - 1 # Antes da primeira pose: ainda no trecho que volta da última.
	var current := poses[index]
	var next: PoseData
	var span: float
	if index + 1 < poses.size():
		next = poses[index + 1]
		span = next.time - current.time
	elif loop:
		next = poses[0]
		span = length - current.time + next.time
	else:
		return current
	var elapsed := t - current.time
	if elapsed < 0.0:
		elapsed += length
	var weight := elapsed / span if span > 0.0 else 1.0
	if current.transition == PoseData.Transition.SMOOTH:
		weight = smoothstep(0.0, 1.0, weight)
	return current.blended(next, weight)
