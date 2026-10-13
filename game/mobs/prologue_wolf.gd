class_name PrologueWolf
extends Mob
## O lobo do prólogo (06-mobs/lobo.md): ataca Nate na borda da mina e, quando a vida baixa até o limite,
## foge mancando pela fenda, e Nate o segue. No prólogo ele não morre.

## Vida em que ele foge, em pontos (11-balanceamento).
@export var flee_health := 0
## Para onde ele foge: a fenda.
@export var flee_point: Node3D
@export var limp_animation: AnimationData

var _fleeing := false


func take_hit(hit: Hit) -> void:
	if _fleeing:
		return
	# O golpe nunca tira a última vida: ele foge antes.
	hit.points = mini(hit.points, health.value - 1)
	super.take_hit(hit)
	if health.value <= flee_health:
		_start_flee()


func _physics_process(delta: float) -> void:
	if not _fleeing:
		super._physics_process(delta)
		return
	var offset := _flat(flee_point.global_position - global_position)
	if offset.length() <= data.move_speed * delta:
		# Sumiu pela fenda: não volta mais.
		SaveSystem.record(SaveSystem.KILLED, save_id)
		queue_free()
		return
	_facing = offset.normalized()
	velocity = _facing * data.move_speed
	if _push_left > 0.0:
		_push_left -= delta
		velocity = _push_velocity
	_move(delta)
	_model.rotation.y = atan2(-_facing.x, -_facing.z)


func _start_flee() -> void:
	_fleeing = true
	_end_attack()
	AudioManager.play(&"wolf_howl", global_position)
	remove_from_group(&"enemies")
	_hurtbox.queue_free()
	# Atravessa Nate e os outros mobs até a fenda.
	collision_mask = HitShape.WORLD_LAYER
	_animator.play(limp_animation)
