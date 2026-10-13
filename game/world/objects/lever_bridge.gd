class_name LeverBridge
extends Node3D
## Ponte de alavanca (08-mapa): baixa sobre o vão quando a alavanca é puxada, de perto ou com um tiro, e vira
## atalho para sempre. Levantada, uma barreira (camada 4) segura quem anda na beira do vão; baixada, o tabuleiro
## é chão firme.

@export var lever: Lever
## Giro da ponte levantada, em graus, e o tempo para baixar, em segundos.
@export var raised_angle := 0.0
@export var lower_time := 0.0
## Vão que a ponte cobre, em blocos: largura (x) e comprimento (para −z, a partir da dobradiça).
@export var span := Vector2.ZERO
## Altura da barreira, em blocos.
@export var barrier_height := 0.0
## Espessura do tabuleiro, em blocos: o chão de quem atravessa a ponte baixada.
@export var deck_thickness := 0.0

var _barrier: CollisionShape3D
var _floor: CollisionShape3D

@onready var _deck: Node3D = $Deck


func _ready() -> void:
	_barrier = _box(HitShape.BARRIER_LAYER, Vector3(span.x, barrier_height, span.y), barrier_height / 2.0)
	# Sem o chão do tabuleiro (camada do mundo), quem atravessa cai no vão.
	_floor = _box(HitShape.WORLD_LAYER, Vector3(span.x, deck_thickness, span.y), -deck_thickness / 2.0)
	lever.pulled.connect(_lower)
	var lowered := SaveSystem.has_record(SaveSystem.OPENED, lever.save_id)
	_set_lowered(lowered)
	if not lowered:
		_deck.rotation_degrees.x = raised_angle


func _lower() -> void:
	var tween := create_tween()
	tween.tween_property(_deck, ^"rotation_degrees:x", 0.0, lower_time)
	# A passagem só abre com o tabuleiro já deitado sobre o vão.
	tween.tween_callback(_set_lowered.bind(true))


func _set_lowered(lowered: bool) -> void:
	_barrier.set_deferred(&"disabled", lowered)
	_floor.set_deferred(&"disabled", not lowered)


# Um corpo parado com uma caixa sobre o vão, na camada dada, centrada na altura dada.
func _box(layer: int, size: Vector3, height: float) -> CollisionShape3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.0, height, -span.y / 2.0)
	body.add_child(collision)
	add_child(body)
	return collision
