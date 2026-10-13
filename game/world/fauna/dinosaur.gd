class_name Dinosaur
extends CharacterBody3D
## Dinossauro do Bosque (06-mobs/README.md): herbívoro de pescoço longo que vive ali sem lutar. Anda devagar
## perto de casa, para e come cogumelos. Não fere nem é ferido; o corpo grande segura quem anda.

enum State { IDLE, WALK, EAT }

@export var idle_animation: AnimationData
@export var walk_animation: AnimationData
@export var eat_animation: AnimationData
## Velocidade de andar, em blocos/s, e até onde ele se afasta de casa, em blocos.
@export var walk_speed := 0.0
@export var wander_radius := 0.0
## Tempo parado (menor e maior) e comendo, em segundos.
@export var idle_time := Vector2.ZERO
@export var eat_time := 0.0
## Chance de comer, em vez de andar, depois de ficar parado (de 0 a 1).
@export var eat_chance := 0.0
## Tempo máximo andando até o ponto escolhido, em segundos; se algo o segura, ele desiste e para.
@export var walk_timeout := 0.0
## Cor e força do brilho fraco das manchas (10-arte-audio).
@export var spot_color := Color.WHITE
@export var spot_glow := 0.0

var state := State.IDLE
var _left := 0.0
var _target := Vector3.ZERO
var _home := Vector3.ZERO
var _rng := RandomNumberGenerator.new()

@onready var _model: BlockModel = $BlockModel
@onready var _animator: ModelAnimator = $BlockModel/ModelAnimator


func _ready() -> void:
	_home = global_position
	# Cada dinossauro com o seu ritmo, sempre o mesmo no mesmo lugar.
	_rng.seed = hash(Vector2i(roundi(global_position.x), roundi(global_position.z)))
	for i in range(1, 7):
		_model.set_part_glow(StringName("spot_%d" % i), spot_color, spot_glow)
	_idle()


func _physics_process(delta: float) -> void:
	_left -= delta
	match state:
		State.IDLE:
			velocity = Vector3.ZERO
			if _left <= 0.0:
				if _rng.randf() < eat_chance:
					_eat()
				else:
					_walk()
		State.WALK:
			var offset := _target - global_position
			offset.y = 0.0
			if offset.length() <= walk_speed * delta or _left <= 0.0:
				_idle()
			else:
				velocity = offset.normalized() * walk_speed
				rotation.y = atan2(-offset.x, -offset.z)
		State.EAT:
			velocity = Vector3.ZERO
			if _left <= 0.0:
				_idle()
	move_and_slide()


func _idle() -> void:
	state = State.IDLE
	_left = _rng.randf_range(idle_time.x, idle_time.y)
	_animator.play(idle_animation)


func _walk() -> void:
	state = State.WALK
	var angle := _rng.randf() * TAU
	_target = _home + Vector3(cos(angle), 0.0, sin(angle)) * _rng.randf() * wander_radius
	_left = walk_timeout
	_animator.play(walk_animation)


func _eat() -> void:
	state = State.EAT
	_left = eat_time
	_animator.play(eat_animation)
