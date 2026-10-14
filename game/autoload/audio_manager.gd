extends Node
## Música por área, sons de ambiente e mixagem com os avisos acima da música (10-arte-audio). Os sons vêm do banco
## (data/audio/sounds.tres), pelo nome; os números e as músicas gerais, de data/audio/audio_rules.tres. Os canais
## (Music, Ambience, Effects e Warnings) ficam em default_bus_layout.tres: a música abaixa sozinha quando toca um
## aviso de golpe.

const BANK_PATH := "res://data/audio/sounds.tres"
const RULES_PATH := "res://data/audio/audio_rules.tres"
## As opções do jogador ficam num arquivo à parte, que "Novo jogo" não apaga (12-tecnico).
const SETTINGS_PATH := "user://settings.cfg"
const MUSIC_BUSES: Array[StringName] = [&"Music", &"Ambience"]
const EFFECT_BUSES: Array[StringName] = [&"Effects", &"Warnings"]

var bank: SoundBank
var rules: AudioRules
## Volumes das opções (09-interface), de 0 a 1: a música, junto com o som de fundo, e os efeitos, junto com os avisos.
var music_volume := 1.0
var effects_volume := 1.0

var _world_voices: Array[AudioStreamPlayer3D] = []
var _screen_voices: Array[AudioStreamPlayer] = []
# Até quando cada voz do mundo está ocupada, em milissegundos.
var _world_busy: Array[int] = []
var _next_world := 0
var _next_screen := 0
var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _music_tween: Tween
var _ambience_tween: Tween
# O que cada um vai tocar no fim da troca em andamento (o que toca agora pode estar sumindo).
var _music_target: AudioStream
var _ambience_target: AudioStream
var _music_stack: Array[AudioStream] = []
# Último quadro com som de menu: abrir um menu e pôr o foco no primeiro botão tocam um só.
var _menu_sound_frame := -1
var _listener: AudioListener3D
var _rng := RandomNumberGenerator.new()
# O volume de cada canal na mixagem (default_bus_layout.tres), antes das opções.
var _base_db := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bank = load(BANK_PATH)
	rules = load(RULES_PATH)
	_rng.randomize()
	for bus: StringName in MUSIC_BUSES + EFFECT_BUSES:
		_base_db[bus] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
	_load_settings()
	for i in rules.world_voices:
		var voice := AudioStreamPlayer3D.new()
		voice.unit_size = rules.unit_size
		voice.max_distance = rules.max_distance
		add_child(voice)
		_world_voices.append(voice)
		_world_busy.append(0)
	for i in rules.screen_voices:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_screen_voices.append(voice)
	_music = _loop_player(&"Music")
	_ambience = _loop_player(&"Ambience")
	# Quem ouve fica em Nate, virado como a câmera: os sons do mundo ficam mais baixos longe dele.
	_listener = AudioListener3D.new()
	add_child(_listener)
	# Os botões dos menus: um som ao trocar de botão e outro ao escolher.
	get_tree().node_added.connect(_on_node_added)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node3D
	var camera := get_viewport().get_camera_3d()
	if player == null or camera == null:
		return
	_listener.global_transform = Transform3D(camera.global_basis, player.global_position)
	if not _listener.is_current():
		_listener.make_current()


## Toca um som do banco. Com [param where], o som sai daquele ponto do mundo; sem ele, toca na tela (menus).
func play(id: StringName, where := Vector3.INF) -> void:
	if id == &"":
		return
	var sound: SoundData = bank.sounds.get(id)
	if sound == null or sound.streams.is_empty():
		push_warning("Som que falta no banco: %s" % id)
		return
	if String(id).begins_with("ui_"):
		if _menu_sound_frame == Engine.get_process_frames():
			return
		_menu_sound_frame = Engine.get_process_frames()
	# Longe demais de Nate, o som do mundo nem toca: não gasta voz.
	if where != Vector3.INF and _listener.is_current() and where.distance_to(_listener.global_position) > rules.max_distance:
		return
	var stream: AudioStream = sound.streams[_rng.randi() % sound.streams.size()]
	var pitch := sound.pitch * (1.0 + _rng.randf_range(-sound.pitch_variation, sound.pitch_variation))
	var voice: Node
	if where == Vector3.INF:
		voice = _screen_voices[_next_screen]
		_next_screen = (_next_screen + 1) % _screen_voices.size()
	else:
		var index := _free_world_voice()
		var world_voice := _world_voices[index]
		_world_busy[index] = Time.get_ticks_msec() + int(stream.get_length() / pitch * 1000.0)
		world_voice.global_position = where
		voice = world_voice
	voice.set(&"stream", stream)
	voice.set(&"volume_db", sound.volume_db)
	voice.set(&"pitch_scale", pitch)
	voice.set(&"bus", sound.bus)
	voice.call(&"play")


## Prepara uma voz própria de quem precisa parar o som no meio (o pilar carregando, que para se Nate soltar): a
## gravação, o volume, o tom e o canal do som do banco.
func prepare(voice: Node, id: StringName) -> void:
	var sound: SoundData = bank.sounds.get(id)
	if sound == null or sound.streams.is_empty():
		push_warning("Som que falta no banco: %s" % id)
		return
	voice.set(&"stream", sound.streams[0])
	voice.set(&"volume_db", sound.volume_db)
	voice.set(&"pitch_scale", sound.pitch)
	voice.set(&"bus", sound.bus)
	if voice is AudioStreamPlayer3D:
		(voice as AudioStreamPlayer3D).unit_size = rules.unit_size
		(voice as AudioStreamPlayer3D).max_distance = rules.max_distance


# A primeira voz do mundo livre a partir da vez; com todas ocupadas, a da vez (a que tocou há mais tempo).
func _free_world_voice() -> int:
	var now := Time.get_ticks_msec()
	for step in _world_voices.size():
		var index := (_next_world + step) % _world_voices.size()
		if _world_busy[index] <= now and not _world_voices[index].playing:
			_next_world = (index + 1) % _world_voices.size()
			return index
	var oldest := _next_world
	_next_world = (_next_world + 1) % _world_voices.size()
	return oldest


## Muda o volume da música (de 0 a 1) e guarda nas opções.
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()
	_save_settings()


## Muda o volume dos efeitos (de 0 a 1) e guarda nas opções.
func set_effects_volume(value: float) -> void:
	effects_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()
	_save_settings()


## Troca a música, sumindo com a de antes. A mesma música continua de onde estava; vazia, a música para.
func play_music(stream: AudioStream) -> void:
	_music_stack.clear()
	_switch_music(stream)


## Uma música por cima da da área (a das arenas, a das memórias), até [method pop_music].
func push_music(stream: AudioStream) -> void:
	_music_stack.append(_music_target)
	_switch_music(stream)


## Volta para a música de antes do [method push_music].
func pop_music() -> void:
	if not _music_stack.is_empty():
		_switch_music(_music_stack.pop_back())


## O som de fundo da área; vazio, ele para.
func play_ambience(stream: AudioStream) -> void:
	if stream == _ambience_target:
		return
	_ambience_target = stream
	if _ambience_tween:
		_ambience_tween.kill()
	_ambience_tween = _fade(_ambience, stream, rules.ambience_volume_db)


func _switch_music(stream: AudioStream) -> void:
	if stream == _music_target:
		return
	_music_target = stream
	if _music_tween:
		_music_tween.kill()
	_music_tween = _fade(_music, stream, rules.music_volume_db)


# Some com o que toca, troca e volta ao volume. Se o que toca já é o pedido (uma troca desfeita no meio), só
# volta ao volume.
func _fade(voice: AudioStreamPlayer, stream: AudioStream, volume_db: float) -> Tween:
	var tween := create_tween()
	if voice.playing and voice.stream == stream:
		tween.tween_property(voice, ^"volume_db", volume_db, rules.fade_time / 2.0)
		return tween
	if voice.playing:
		tween.tween_property(voice, ^"volume_db", rules.silent_db, rules.fade_time / 2.0)
	tween.tween_callback(func() -> void:
		voice.stream = stream
		if stream == null:
			voice.stop()
			return
		_set_loop(stream)
		voice.volume_db = rules.silent_db
		voice.play())
	if stream != null:
		tween.tween_property(voice, ^"volume_db", volume_db, rules.fade_time / 2.0)
	return tween


func _set_loop(stream: AudioStream) -> void:
	if &"loop" in stream:
		stream.set(&"loop", true)


func _apply_volumes() -> void:
	for bus: StringName in MUSIC_BUSES + EFFECT_BUSES:
		var share := music_volume if bus in MUSIC_BUSES else effects_volume
		var index := AudioServer.get_bus_index(bus)
		AudioServer.set_bus_mute(index, share <= 0.0)
		AudioServer.set_bus_volume_db(index, _base_db[bus] + linear_to_db(maxf(share, 0.001)))


func _load_settings() -> void:
	var settings := ConfigFile.new()
	if settings.load(SETTINGS_PATH) == OK:
		music_volume = clampf(settings.get_value("audio", "music", 1.0), 0.0, 1.0)
		effects_volume = clampf(settings.get_value("audio", "effects", 1.0), 0.0, 1.0)
	_apply_volumes()


func _save_settings() -> void:
	var settings := ConfigFile.new()
	settings.load(SETTINGS_PATH)
	settings.set_value("audio", "music", music_volume)
	settings.set_value("audio", "effects", effects_volume)
	settings.save(SETTINGS_PATH)


func _loop_player(bus: StringName) -> AudioStreamPlayer:
	var voice := AudioStreamPlayer.new()
	voice.bus = bus
	voice.volume_db = rules.silent_db
	add_child(voice)
	return voice


func _on_node_added(node: Node) -> void:
	var button := node as BaseButton
	# Os espaços de item tocam os próprios sons: pegar, trocar e recusar (ItemMoves).
	if button and not button is ItemCell and not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	play(&"ui_confirm")


func _on_focus_changed(_control: Control) -> void:
	play(&"ui_move")
