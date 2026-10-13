class_name LeverBridge
extends Node3D
## Ponte de alavanca (08-mapa): baixa sobre o vão quando a alavanca é puxada, de perto ou com um tiro, e vira
## atalho para sempre. Levantada, uma barreira (camada 4) segura quem anda na beira do vão.

@export var lever: Lever
## Giro da ponte levantada, em graus, e o tempo para baixar, em segundos.
@export var raised_angle := 0.0
@export var lower_time := 0.0
## Vão que a ponte cobre, em blocos: largura (x) e comprimento (para −z, a partir da dobradiça).
@export var span := Vector2.ZERO
## Altura da barreira, em blocos.
@export var barrier_height := 0.0

var _barrier: CollisionShape3D

@onready var _deck: Node3D = $Deck


func _ready() -> void:
	var body := StaticBody3D.new()
	body.collision_layer = HitShape.BARRIER_LAYER
	body.collision_mask = 0
	var shape := BoxShape3D.new()
	shape.size = Vector3(span.x, barrier_height, span.y)
	_barrier = CollisionShape3D.new()
	_barrier.shape = shape
	_barrier.position = Vector3(0.0, barrier_height / 2.0, -span.y / 2.0)
	body.add_child(_barrier)
	add_child(body)
	lever.pulled.connect(_lower)
	if SaveSystem.has_record(SaveSystem.OPENED, lever.save_id):
		_barrier.disabled = true
	else:
		_deck.rotation_degrees.x = raised_angle


func _lower() -> void:
	_barrier.set_deferred(&"disabled", true)
	create_tween().tween_property(_deck, ^"rotation_degrees:x", 0.0, lower_time)
