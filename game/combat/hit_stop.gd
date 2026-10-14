class_name HitStop
## Pausa curta no acerto (10-arte-audio): o tempo do jogo quase para por um instante, para o golpe ter peso. Uma
## pausa nova no meio de outra só estende até o fim da maior; só a última devolve o tempo normal.

static var _until_msec := 0
static var _latest := 0


## Quase para o jogo por [param seconds] (tempo de verdade), andando a [param scale] da velocidade.
static func freeze(seconds: float, scale: float) -> void:
	if seconds <= 0.0:
		return
	var until := Time.get_ticks_msec() + roundi(seconds * 1000.0)
	if until <= _until_msec:
		return
	_until_msec = until
	_latest += 1
	var mine := _latest
	Engine.time_scale = scale
	var tree := Engine.get_main_loop() as SceneTree
	tree.create_timer(seconds, true, false, true).timeout.connect(func() -> void:
		if mine == _latest:
			Engine.time_scale = 1.0)
