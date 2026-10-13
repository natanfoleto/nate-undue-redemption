class_name Player
extends CharacterBody3D
## Nate (04-player): anda, olha para onde anda, mira e rola. Os números vêm do Balance.

@export var idle_animation: AnimationData
@export var walk_animation: AnimationData
@export var roll_animation: AnimationData

## Direção da mira no chão, de tamanho 1. Os ataques vão nessa direção.
var aim_direction := Vector3.FORWARD
## Para onde Nate olha, no chão, de tamanho 1.
var facing := Vector3.FORWARD
## Invencível enquanto rola.
var is_invincible := false

var _roll_time_left := 0.0
var _roll_cooldown_left := 0.0
var _roll_direction := Vector3.ZERO

@onready var _model: BlockModel = $BlockModel
@onready var _animator: ModelAnimator = $BlockModel/ModelAnimator
@onready var _aim_arrow: Node3D = $AimArrow


func _physics_process(delta: float) -> void:
	var move := _ground_direction(Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down"))
	if not is_rolling():
		_roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)
		if Input.is_action_just_pressed(&"dodge") and is_zero_approx(_roll_cooldown_left):
			_start_roll(move)
	if is_rolling():
		_update_roll(delta)
	else:
		_walk(move, delta)
	move_and_slide()
	_update_facing()
	_update_aim(move)
	_update_animation()


func is_rolling() -> bool:
	return _roll_time_left > 0.0


## A mira puxada para o inimigo mais próximo dentro do cone da ajuda de mira (04-player).
func assisted_aim() -> Vector3:
	var stats := Balance.player
	var best_offset := Vector3.ZERO
	for enemy: Node3D in get_tree().get_nodes_in_group(&"enemies"):
		var offset := enemy.global_position - global_position
		offset.y = 0.0
		if offset.is_zero_approx() or offset.length() > stats.aim_assist_range:
			continue
		# O cone se abre metade para cada lado da mira.
		if rad_to_deg(aim_direction.angle_to(offset)) > stats.aim_assist_angle / 2.0:
			continue
		if best_offset.is_zero_approx() or offset.length() < best_offset.length():
			best_offset = offset
	return aim_direction if best_offset.is_zero_approx() else best_offset.normalized()


func _walk(move: Vector3, delta: float) -> void:
	var stats := Balance.player
	var rate := stats.move_speed / stats.acceleration_time
	velocity = velocity.move_toward(move * stats.move_speed, rate * delta)


func _start_roll(move: Vector3) -> void:
	var stats := Balance.player
	_roll_direction = facing if move.is_zero_approx() else move
	_roll_time_left = stats.roll_duration
	is_invincible = true
	_animator.play(roll_animation)
	_animator.speed_scale = roll_animation.length / stats.roll_duration


# Anda exatamente a distância do rolamento: o último passo da física só cobre o tempo que faltava.
func _update_roll(delta: float) -> void:
	var stats := Balance.player
	var step := minf(delta, _roll_time_left)
	velocity = _roll_direction * (stats.roll_distance / stats.roll_duration) * (step / delta)
	_roll_time_left -= step
	if _roll_time_left <= 0.0:
		_roll_time_left = 0.0
		is_invincible = false
		_roll_cooldown_left = stats.roll_cooldown


func _update_facing() -> void:
	var ground_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if not ground_velocity.is_zero_approx():
		facing = ground_velocity.normalized()
	_model.rotation.y = atan2(-facing.x, -facing.z)


# Teclado e mouse: na direção do cursor. Controle: na do analógico direito; solto, na do movimento.
func _update_aim(move: Vector3) -> void:
	var direction: Vector3
	if InputManager.is_gamepad():
		direction = _ground_direction(Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down"))
		if direction.is_zero_approx():
			direction = facing if move.is_zero_approx() else move
	else:
		direction = _cursor_offset()
	if not direction.is_zero_approx():
		aim_direction = direction.normalized()
	# A seta já mostra a mira puxada pela ajuda de mira, para onde o golpe vai de fato.
	var shown := assisted_aim()
	_aim_arrow.rotation.y = atan2(-shown.x, -shown.z)


func _update_animation() -> void:
	if is_rolling():
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if is_zero_approx(speed):
		_animator.play(idle_animation)
		_animator.speed_scale = 1.0
	else:
		_animator.play(walk_animation)
		_animator.speed_scale = speed / Balance.player.move_speed


# Uma direção da tela (x para a direita, y para baixo) vira uma direção no chão, de acordo com a câmera.
# Sempre de tamanho 1: Nate tem uma velocidade só (04-player), e o analógico inclinado de leve anda como o teclado.
func _ground_direction(screen: Vector2) -> Vector3:
	if screen.is_zero_approx():
		return Vector3.ZERO
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3(screen.x, 0.0, screen.y).normalized()
	var right := Vector3(camera.global_basis.x.x, 0.0, camera.global_basis.x.z).normalized()
	var down := Vector3(camera.global_basis.z.x, 0.0, camera.global_basis.z.z).normalized()
	return (right * screen.x + down * screen.y).normalized()


# Do pé de Nate até o ponto do chão embaixo do cursor.
func _cursor_offset() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3.ZERO
	var mouse := get_viewport().get_mouse_position()
	var hit: Variant = Plane(Vector3.UP, global_position.y).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
	if hit == null:
		return Vector3.ZERO
	var offset: Vector3 = hit - global_position
	offset.y = 0.0
	return offset
