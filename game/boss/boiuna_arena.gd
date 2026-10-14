class_name BoiunaArena
extends Node3D
## A luta da Grande Prisão (07-chefes/boiuna): quando Nate entra na arena, a porta fecha atrás dele, a Boiúna sai do
## fosso e a barra dela aparece. Na fase 1, cada pilar que Nate ativa a prende com uma corrente de luz; com os 4, vem a
## cena da troca de fase: ela se solta de duas correntes, ruge, a arena apaga e ela some no fosso. Na fase 2, a luta
## é na escuridão, só com a Luz Ancestral. Se Nate morre na fase 1, a luta recomeça do início; na fase 2, ela recomeça
## na fase 2, com os pilares acesos. Vencida a fase 2, as correntes a puxam para o fundo, a prisão fecha, e vêm a cena
## final, os créditos e o resumo; depois, Nate volta ao santuário, com a arena vazia (02-core-loop).

enum State { WAITING, FIGHTING, SCENE, SEALED }

## Identificadores no jogo salvo: a prisão fechada (a luta vencida), a fase 2 alcançada e o fim visto (a cena final,
## os créditos e o resumo).
@export var save_id: StringName
@export var phase_2_id: StringName
@export var ending_id: StringName
## Retângulo do chão da arena, centrado no nó (o centro do fosso), em blocos: a luta começa quando Nate entra nele.
@export var area_size := Vector2.ZERO
@export var boiuna: Boiuna
@export var door: PrisonDoor
@export var pillars: Array[PrisonPillar] = []
## A escuridão da fase 2, a luz do ambiente acesa (fase 1) e apagada (fase 2) e as luzes da arena, que apagam junto.
@export var dark_area: DarkArea
@export var world: WorldEnvironment
@export var lit_ambient := 0.0
@export var dark_ambient := 0.0
@export var arena_lights: Array[Light3D] = []
@export var camera: FollowCamera
## A tampa de jade que fecha o fosso no fim.
@export var seal: Node3D
@export var chain_scene: PackedScene
@export var hint_director: HintDirector
@export var pillar_hint: HintData
## O santuário da antessala: depois do fim, Nate volta a ele.
@export var sanctuary: SanctuaryData
## A música da luta, por cima da da área, e a do fim (a cena final e os créditos).
@export var music: AudioStream
@export var ending_music: AudioStream
## As cenas do fim, em ordem: a cena final, os créditos e o resumo da partida.
@export var ending_scenes: Array[PackedScene] = []

@export_group("Tempos")
## A câmera puxa para o centro da arena durante a luta (0 só Nate, 1 só o centro) e, nas cenas, olha só para ele; o
## tempo da puxada, em segundos.
@export var focus_weight := 0.0
@export var focus_time := 0.0
## Tempo para a corrente nascer do pilar até a Boiúna, em segundos.
@export var chain_time := 0.0
## A troca de fase: quanto tempo ela se debate, quando cada uma das duas correntes rompe (em segundos desde o
## começo) e o tempo da arena apagando.
@export var thrash_time := 0.0
@export var chain_breaks: Array[float] = []
@export var dark_time := 0.0
## O fim: o tempo das correntes puxando a Boiúna para o fundo, o da tampa fechando o fosso e a espera antes da cena
## final, em segundos.
@export var seal_pull_time := 0.0
@export var seal_close_time := 0.0
@export var seal_hold_time := 0.0
## A respiração da Boiúna dormindo no fosso, antes da luta: a cada tantos segundos.
@export var breath_every := 0.0

var state := State.WAITING
var _chains: Array[LightChain] = []
var _broken: Array[bool] = []
var _breath_left := 0.0
var _light_energy: Array[float] = []


func _ready() -> void:
	for pillar in pillars:
		pillar.hold_time = boiuna.data.pillar_hold_time
		pillar.activated.connect(_on_pillar_activated)
		var chain := chain_scene.instantiate() as LightChain
		add_child(chain)
		chain.visible = false
		_chains.append(chain)
		_broken.append(false)
	for light in arena_lights:
		_light_energy.append(light.light_energy)
	boiuna.part_broken.connect(_on_part_broken)
	boiuna.defeated.connect(_on_defeated)
	Events.player_respawned.connect(_on_player_respawned)
	seal.visible = false
	# Depois de a porta, os pilares e a Boiúna ficarem prontos.
	_begin.call_deferred()


func _begin() -> void:
	if not SaveSystem.has_record(SaveSystem.OPENED, save_id):
		_wait_for_fight()
		return
	_show_sealed()
	# O jogo fechou no meio do fim: ele passa de novo, sem a luta.
	if not SaveSystem.has_record(SaveSystem.OPENED, ending_id):
		_play_ending()


func _physics_process(delta: float) -> void:
	if state == State.WAITING:
		if _player_inside():
			_start_fight()
		elif not _reached_phase_2():
			# Antes da luta, ela respira no fundo do fosso.
			_breath_left -= delta
			if _breath_left <= 0.0:
				_breath_left = breath_every
				AudioManager.play(&"boiuna_breath", global_position)


func _process(_delta: float) -> void:
	for i in _chains.size():
		var chain := _chains[i]
		if chain.visible:
			chain.from = pillars[i].crystal_point()
			chain.to = boiuna.chain_anchor()


# Antes da luta (ou depois de Nate morrer nela): a porta aberta e a Boiúna dormindo. Na fase 2 alcançada, os pilares
# ficam acesos e as duas correntes que restaram descem para o fosso.
func _wait_for_fight() -> void:
	state = State.WAITING
	boiuna.sleep()
	_set_dark(false, 0.0)
	var phase_2 := _reached_phase_2()
	for i in pillars.size():
		if phase_2:
			pillars[i].light_up()
		else:
			pillars[i].reset()
		_broken[i] = phase_2 and i < chain_breaks.size()
		_chains[i].visible = phase_2 and not _broken[i]
		_chains[i].fill = 1.0


func _start_fight() -> void:
	state = State.FIGHTING
	door.close()
	door.locked = true
	AudioManager.push_music(music)
	camera.set_focus(global_position, focus_weight, focus_time)
	var phase_2 := _reached_phase_2()
	boiuna.wake(phase_2)
	var bar := _boss_bar()
	if bar:
		bar.track(boiuna)
	if phase_2:
		_set_dark(true, dark_time)
		return
	for pillar in pillars:
		pillar.armed = true


# Uma parte da vida caiu e ela está atordoada: a hora segura de ativar um pilar.
func _on_part_broken() -> void:
	hint_director.show_hint(pillar_hint)


func _on_pillar_activated(pillar: PrisonPillar) -> void:
	var index := pillars.find(pillar)
	var chain := _chains[index]
	chain.fill = 0.0
	chain.visible = true
	create_tween().tween_property(chain, ^"fill", 1.0, chain_time)
	AudioManager.play(&"chain_bind", pillar.global_position)
	hint_director.finish_hint(pillar_hint)
	var lit := pillars.filter(func(other: PrisonPillar) -> bool: return other.active).size()
	boiuna.pillars_active = lit
	if lit == pillars.size():
		_change_phase()


# A troca de fase (10-arte-audio): presa pelos 4 pilares, ela se debate, rompe duas correntes, ruge, e a arena
# apaga; ela some no fosso, e a luta segue na escuridão.
func _change_phase() -> void:
	state = State.SCENE
	SaveSystem.record(SaveSystem.OPENED, phase_2_id)
	var player := _player()
	player.set_cinematic(true)
	for pillar in pillars:
		pillar.armed = false
	camera.set_focus(global_position, 1.0, focus_time)
	boiuna.play_scripted(Boiuna.Scripted.THRASH, thrash_time)
	AudioManager.play(&"boiuna_roar", global_position)
	Events.screen_shake.emit(boiuna.data.roar_shake, boiuna.data.roar_shake_time)
	var elapsed := 0.0
	for i in chain_breaks.size():
		await _wait(chain_breaks[i] - elapsed)
		elapsed = chain_breaks[i]
		_break_chain(i)
	AudioManager.play(&"boiuna_roar", global_position)
	_set_dark(true, dark_time)
	await _wait(maxf(thrash_time - elapsed, dark_time))
	boiuna.play_scripted(Boiuna.Scripted.DIVE, boiuna.data.dive_time)
	await _wait(boiuna.data.dive_time)
	camera.set_focus(global_position, focus_weight, focus_time)
	player.set_cinematic(false)
	boiuna.start_phase_2()
	state = State.FIGHTING


func _break_chain(index: int) -> void:
	var chain := _chains[index]
	_broken[index] = true
	chain.visible = false
	# Os elos se desfazem em cubinhos de luz ao longo da corrente.
	var pieces := maxi(roundi(chain.from.distance_to(chain.to) / boiuna.data.splash_radius), 1)
	for i in pieces + 1:
		var where := chain.from.lerp(chain.to, float(i) / pieces)
		SpellEffects.burst(get_parent(), where, chain.color, boiuna.data.splash_radius / 2.0, boiuna.data.splash_look)
	AudioManager.play(&"chain_break", chain.to)
	Events.screen_shake.emit(boiuna.data.slam_shake, boiuna.data.slam_shake_time)


# Nate voltou depois de morrer: na luta, ela recomeça (do início na fase 1; na fase 2, na fase 2).
func _on_player_respawned() -> void:
	if state != State.FIGHTING:
		return
	_release_bar()
	camera.clear_focus(focus_time)
	AudioManager.pop_music()
	door.locked = false
	door.open()
	_wait_for_fight()


# Vencida a fase 2: as correntes rompidas voltam, as quatro a puxam para o fundo, a tampa de jade fecha o fosso e a
# luz volta; depois, a cena final, os créditos e o resumo.
func _on_defeated() -> void:
	state = State.SCENE
	SaveSystem.record(SaveSystem.OPENED, save_id)
	GameState.set_respawn_point(sanctuary.id(), sanctuary.area)
	var player := _player()
	player.set_cinematic(true)
	_release_bar()
	camera.set_focus(global_position, 1.0, focus_time)
	for i in _chains.size():
		if not _chains[i].visible:
			_chains[i].fill = 0.0
			_chains[i].visible = true
			create_tween().tween_property(_chains[i], ^"fill", 1.0, chain_time)
	AudioManager.play(&"chain_bind", global_position)
	boiuna.play_scripted(Boiuna.Scripted.SEAL, seal_pull_time)
	AudioManager.play(&"boiuna_roar", global_position)
	await _wait(seal_pull_time)
	for chain in _chains:
		chain.visible = false
	_close_seal()
	_set_dark(false, dark_time)
	AudioManager.pop_music()
	await _wait(seal_close_time + seal_hold_time)
	await _play_ending()


func _close_seal() -> void:
	seal.visible = true
	# Quase zero, e não zero: uma escala zero não tem inversa.
	seal.scale = Vector3(0.01, 1.0, 0.01)
	create_tween().tween_property(seal, ^"scale", Vector3.ONE, seal_close_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	AudioManager.play(&"prison_close", global_position)
	Events.screen_shake.emit(boiuna.data.roar_shake, boiuna.data.roar_shake_time)


# A cena final, os créditos e o resumo, um depois do outro, com o tema principal; no fim, Nate volta ao santuário da
# antessala, com o predador preso, para achar o que faltou.
func _play_ending() -> void:
	await GameState.fade_out()
	AudioManager.push_music(ending_music)
	for scene in ending_scenes:
		var screen := scene.instantiate()
		get_tree().current_scene.add_child(screen)
		GameState.fade_in()
		await screen.finished
	SaveSystem.record(SaveSystem.OPENED, ending_id)
	GameState.change_area(sanctuary.area, sanctuary.id())


# A prisão já fechada (o jogo salvo depois do fim): a arena vazia, os pilares acesos, a tampa no fosso e a porta
# aberta.
func _show_sealed() -> void:
	state = State.SEALED
	boiuna.sleep()
	seal.visible = true
	for pillar in pillars:
		pillar.light_up()
	door.open(false)


# A arena apaga (a fase 2) ou acende: a luz do ambiente, a escuridão do chão e a luz de cima dos pilares.
func _set_dark(on: bool, seconds: float) -> void:
	dark_area.set_dark(on, seconds)
	var energy := dark_ambient if on else lit_ambient
	if seconds <= 0.0:
		world.environment.ambient_light_energy = energy
	else:
		create_tween().tween_property(world.environment, ^"ambient_light_energy", energy, seconds)
	for pillar in pillars:
		pillar.show_dark(on)
	for i in arena_lights.size():
		var light_energy := 0.0 if on else _light_energy[i]
		if seconds <= 0.0:
			arena_lights[i].light_energy = light_energy
		else:
			create_tween().tween_property(arena_lights[i], ^"light_energy", light_energy, seconds)


func _reached_phase_2() -> bool:
	return SaveSystem.has_record(SaveSystem.OPENED, phase_2_id)


# A espera é um tween da arena: para com o jogo pausado e some junto com ela (voltar ao menu no meio de uma cena).
func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await create_tween().tween_interval(seconds).finished


func _player() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player


func _boss_bar() -> BossBar:
	return get_tree().get_first_node_in_group(&"boss_bar") as BossBar


func _release_bar() -> void:
	var bar := _boss_bar()
	if bar:
		bar.release()


func _player_inside() -> bool:
	var player := _player()
	if player == null or player.is_dead():
		return false
	var offset := player.global_position - global_position
	return absf(offset.x) <= area_size.x / 2.0 and absf(offset.z) <= area_size.y / 2.0
