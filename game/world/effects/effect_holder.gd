class_name EffectHolder
extends Node3D
## Um efeito de partículas no mundo (SpellEffects): cada camada começa na hora dela, as que giram giram, ele segue
## alguém (o projétil, Nate, a área da magia) ou corre de um ponto a outro, e a luz dele apaga aos poucos. Ao acabar,
## para de soltar cubinhos e espera os últimos sumirem antes de sair.

## Quem o efeito segue; nulo fica parado. Quando quem ele segue sai do jogo, o efeito acaba.
var follow: Node3D:
	set(value):
		follow = value
		_following = value != null

# Um nó liberado compara igual a null: por isso o efeito guarda à parte que está seguindo alguém.
var _following := false
var _layers: Array[CPUParticles3D] = []
var _starts: Array[float] = []
var _started: Array[bool] = []
var _spins: Dictionary[Node3D, float] = {}
var _time := 0.0
var _end_at := -1.0
var _released := false
var _free_at := 0.0
var _sweep_from := Vector3.ZERO
var _sweep_to := Vector3.ZERO
var _sweep_time := 0.0
var _light: OmniLight3D
var _light_energy := 0.0
var _light_fade := 0.0
var _light_hold := false
var _light_fade_from := 0.0


## Põe uma camada, que começa depois de [param start_after] segundos; com [param spin_turns], ela gira em volta do
## centro (voltas por segundo).
func add_layer(particles: CPUParticles3D, start_after: float, spin_turns: float) -> void:
	particles.emitting = false
	if spin_turns != 0.0:
		var spinner := Node3D.new()
		add_child(spinner)
		spinner.add_child(particles)
		_spins[spinner] = spin_turns
	else:
		add_child(particles)
	_layers.append(particles)
	_starts.append(start_after)
	_started.append(false)


## Acaba sozinho quando o último estouro some (só camadas de uma vez) ou depois de [param seconds].
func end_after(seconds: float) -> void:
	_end_at = seconds


## Corre de [param from] até [param to] em [param seconds] e acaba lá.
func sweep(from: Vector3, to: Vector3, seconds: float) -> void:
	_sweep_from = from
	_sweep_to = to
	_sweep_time = seconds
	global_position = from
	_end_at = seconds


## Uma luz no efeito. Sem [param hold], ela apaga em [param fade] segundos; com ele, fica acesa até o efeito acabar e
## só então apaga.
func set_light(color: Color, energy: float, light_range: float, fade: float, hold: bool) -> void:
	_light = OmniLight3D.new()
	_light.light_color = color
	_light.light_energy = energy
	_light.omni_range = light_range
	add_child(_light)
	_light_energy = energy
	_light_fade = fade
	_light_hold = hold
	_light_fade_from = 0.0


## Para de soltar cubinhos e sai quando o último sumir.
func release() -> void:
	if _released:
		return
	_released = true
	follow = null
	var longest := 0.0
	for particles in _layers:
		particles.emitting = false
		longest = maxf(longest, particles.lifetime)
	if _light and _light_hold:
		_light_hold = false
		_light_fade_from = _time
	_free_at = _time + maxf(longest, _light_fade)


func _process(delta: float) -> void:
	_time += delta
	if not _released:
		for i in _layers.size():
			if not _started[i] and _time >= _starts[i]:
				_started[i] = true
				_layers[i].emitting = true
	for spinner in _spins:
		spinner.rotate_y(TAU * _spins[spinner] * delta)
	if _following:
		if is_instance_valid(follow) and follow.is_inside_tree():
			global_position = follow.global_position
		else:
			release()
	if _sweep_time > 0.0 and not _released:
		global_position = _sweep_from.lerp(_sweep_to, minf(_time / _sweep_time, 1.0))
	if _light:
		var faded := 1.0
		if not _light_hold and _light_fade > 0.0:
			faded = clampf(1.0 - (_time - _light_fade_from) / _light_fade, 0.0, 1.0)
		_light.light_energy = _light_energy * faded
	if not _released and _end_at >= 0.0 and _time >= _end_at:
		release()
	if _released and _time >= _free_at:
		queue_free()
