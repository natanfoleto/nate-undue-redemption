class_name StatusVisuals
extends Node3D
## Sinais dos efeitos de status (10-arte-audio): partículas em quem sofre e, nos mobs, um ícone para cada
## efeito sobre a cabeça (09-interface). Em Nate, os ícones ficam no HUD, ao lado dos corações.
## A cena tem uma partícula por efeito, com o nome do efeito (STUN, SLOW, POISON, BURN).

## Ícone de cada efeito, na ordem de StatusEffects.Effect.
@export var icons: Array[Texture2D] = []
## Mostra os ícones sobre a cabeça (mobs).
@export var show_icons := false
## Tamanho de cada ícone sobre a cabeça, em blocos, e quanto ele fica acima da cabeça.
@export var icon_size := 0.0
@export var icon_lift := 0.0

@export var status: StatusEffects

var _icon_nodes: Array[Sprite3D] = []
var _height := 0.0


func _ready() -> void:
	status.changed.connect(_refresh)
	_refresh()


## Acerta os sinais na altura de quem sofre: as estrelas e os ícones acima da cabeça, as partículas azuis nos
## pés e as bolhas e chamas no corpo.
func fit(height: float) -> void:
	_height = height
	var stun := get_node_or_null(^"STUN") as Node3D
	if stun:
		stun.position.y = height
	for body_effect in [^"POISON", ^"BURN"]:
		var particles := get_node_or_null(body_effect) as CPUParticles3D
		if particles:
			particles.position.y = height / 2.0
			particles.emission_box_extents.y = height / 2.0
	_refresh()


func _refresh() -> void:
	var active := status.active()
	for effect: StatusEffects.Effect in StatusEffects.Effect.values():
		var particles := get_node_or_null(NodePath(StatusEffects.Effect.keys()[effect])) as CPUParticles3D
		if particles:
			particles.emitting = effect in active
	if not show_icons:
		return
	for node in _icon_nodes:
		node.queue_free()
	_icon_nodes.clear()
	for i in active.size():
		var icon := Sprite3D.new()
		icon.texture = icons[active[i]]
		icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		icon.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		icon.pixel_size = icon_size / icon.texture.get_width()
		icon.no_depth_test = true
		icon.position = Vector3((i - (active.size() - 1) / 2.0) * icon_size, _height + icon_lift, 0.0)
		add_child(icon)
		_icon_nodes.append(icon)
