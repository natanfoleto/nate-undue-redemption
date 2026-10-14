class_name PrisonPillar
extends Interactable
## Pilar da Grande Prisão (07-chefes/boiuna): na fase 1 da luta, Nate o ativa segurando interagir, parado e de braços
## estendidos, enquanto uma corrente de luz vai do muiraquitã até o cristal. Se levar um golpe ou soltar o botão, a
## ativação para. Ativo, a faixa e o cristal de jade acendem, e a luta prende a Boiúna nele com outra corrente. Só
## aceita a ativação quando a luta deixa (armed); pronto para ativar, o cristal pulsa fraco, para Nate achar onde ir.

signal activated(pillar: PrisonPillar)

## Cor e força do brilho da faixa e do cristal acesos, e a força da luz em cima do pilar.
@export var glow_color := Color.WHITE
@export var lit_glow := 0.0
@export var light_energy := 0.0
## O pulso do cristal enquanto o pilar está pronto para ativar: o brilho mais forte e o tempo de uma volta, em
## segundos.
@export var armed_glow := 0.0
@export var pulse_time := 0.0
## Quanto o pilar acende enquanto Nate segura, até a ativação (o resto acende de uma vez no fim).
@export var charge_glow_share := 0.0
## Na escuridão da fase 2, quanto do brilho fica (a luz de cima apaga).
@export var dark_glow_share := 1.0

## A luta deixa ativar (só na fase 1), e o tempo segurando interagir, em segundos (vem da Boiúna).
var armed := false:
	set(value):
		armed = value
		if is_node_ready() and not active and not _channeling:
			_show_lit(0.0)
var hold_time := 0.0
var active := false

var _channeling := false
var _progress := 0.0
var _pulse := 0.0
var _dark := false
var _player: Player

@onready var _model: BlockModel = $Model
@onready var _light: OmniLight3D = $Light
@onready var _charge_sound: AudioStreamPlayer3D = $ChargeSound
@onready var _chain: LightChain = $Chain


func _ready() -> void:
	super._ready()
	AudioManager.prepare(_charge_sound, &"pillar_charge")
	_chain.visible = false
	_show_lit(0.0)


func can_interact() -> bool:
	return armed and not active and not _channeling


func interact() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Player
	_channeling = true
	_progress = 0.0
	var toward := global_position - _player.global_position
	toward.y = 0.0
	if not toward.is_zero_approx():
		_player.facing = toward.normalized()
	_player.hold_still(true)
	_player.hit_taken.connect(_stop_channel)
	_charge_sound.play()
	_chain.fill = 0.0
	_chain.visible = true


## Ativo de uma vez, sem a espera (a luta voltando na fase 2, com os pilares já ativos; a prisão já fechada).
func light_up() -> void:
	if _channeling:
		_stop_channel()
	active = true
	_show_lit(1.0)


## Apagado de novo (a luta recomeçando do início).
func reset() -> void:
	if _channeling:
		_stop_channel()
	active = false
	armed = false
	_show_lit(0.0)


## Na escuridão da fase 2, a luz de cima apaga e o brilho baixa; o cristal continua aceso, como um farol.
func show_dark(on: bool) -> void:
	_dark = on
	_show_lit(1.0 if active else 0.0)


## O ponto do cristal, de onde sai a corrente de luz.
func crystal_point() -> Vector3:
	return _model.part_center(&"crystal")


func _process(delta: float) -> void:
	if not _channeling:
		if armed and not active and pulse_time > 0.0:
			_pulse = fmod(_pulse + delta / pulse_time, 1.0)
			_show_crystal(armed_glow * (0.5 - 0.5 * cos(TAU * _pulse)))
		return
	if not armed or _player.is_dead() or not Input.is_action_pressed(&"interact"):
		_stop_channel()
		return
	_progress += delta
	_chain.from = _player.amulet_point()
	_chain.to = crystal_point()
	_chain.fill = _progress / hold_time
	# A faixa e o cristal vão acendendo enquanto Nate segura.
	_show_lit(_progress / hold_time * charge_glow_share)
	if _progress >= hold_time:
		_stop_channel()
		active = true
		_show_lit(1.0)
		AudioManager.play(&"pillar_on", global_position)
		activated.emit(self)


# Para de segurar: Nate volta a se mexer, o som e a corrente somem e o pilar apaga (se não acabou de acender).
func _stop_channel() -> void:
	if not _channeling:
		return
	_channeling = false
	_charge_sound.stop()
	_chain.visible = false
	if _player.hit_taken.is_connected(_stop_channel):
		_player.hit_taken.disconnect(_stop_channel)
	_player.hold_still(false)
	_show_lit(0.0)


func _show_lit(weight: float) -> void:
	var glow := lit_glow * weight * (dark_glow_share if _dark else 1.0)
	for part in [&"band", &"crystal"]:
		_model.set_part_glow(part, glow_color, glow)
	_light.light_energy = light_energy * weight
	_light.visible = weight > 0.0 and not _dark


func _show_crystal(strength: float) -> void:
	_model.set_part_glow(&"crystal", glow_color, strength)
