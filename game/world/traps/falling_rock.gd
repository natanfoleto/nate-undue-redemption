class_name FallingRock
extends Node3D
## Pedras que caem (08-mapa): quando Nate ou um mob passa por baixo, a marca aparece no chão e, depois do
## aviso, a pedra cai e fere quem estiver na marca, Nate ou mob. Cai uma vez só.

enum State { WAITING, WARNING, FALLING, FALLEN }

## Identificador único no mapa: a pedra que caiu não volta.
@export var save_id: StringName
## O golpe da pedra: círculo, aviso, dano em corações (Nate) e em pontos (mobs) e recuo.
@export var attack: AttackData
## Altura de onde a pedra cai, em blocos, e o tempo da queda, em segundos.
@export var fall_height := 0.0
@export var fall_time := 0.0

var state := State.WAITING
var _left := 0.0
var _already_hit: Array[Node3D] = []

@onready var _rock: Node3D = $Rock
@onready var _marker: WarningMarker = $WarningMarker


func _ready() -> void:
	_rock.position.y = fall_height
	if SaveSystem.has_record(SaveSystem.OPENED, save_id):
		_rock.position.y = 0.0
		state = State.FALLEN


func _physics_process(delta: float) -> void:
	match state:
		State.WAITING:
			if _someone_below():
				state = State.WARNING
				_left = attack.windup
				_marker.show_attack(attack, global_position, Vector3.FORWARD)
		State.WARNING:
			_left -= delta
			_marker.set_progress(clampf(1.0 - _left / attack.windup, 0.0, 1.0))
			if _left <= 0.0:
				state = State.FALLING
				_left = fall_time
				create_tween().tween_property(_rock, ^"position:y", 0.0, fall_time)
		State.FALLING:
			_left -= delta
			if _left <= 0.0:
				_land()


# Fere quem estiver na marca: Nate em corações, os mobs em pontos (03-regras).
func _land() -> void:
	state = State.FALLEN
	_marker.hide_attack()
	SaveSystem.record(SaveSystem.OPENED, save_id)
	for faction: Hurtbox.Faction in [Hurtbox.Faction.PLAYER, Hurtbox.Faction.ENEMY]:
		Strike.hit_area(attack, self, global_position, Vector3.FORWARD, faction, _already_hit, _build_hit)


func _build_hit(receiver: Node3D) -> Hit:
	var hit := Hit.new()
	hit.attacker = self
	hit.hearts = attack.damage_hearts
	hit.points = attack.damage_points
	hit.knockback = attack.knockback
	var away := receiver.global_position - global_position
	away.y = 0.0
	hit.direction = away.normalized() if not away.is_zero_approx() else Vector3.FORWARD
	return hit


func _someone_below() -> bool:
	for group in [&"player", &"enemies"]:
		for body: Node3D in get_tree().get_nodes_in_group(group):
			var offset := body.global_position - global_position
			if Vector2(offset.x, offset.z).length() <= attack.reach:
				return true
	return false
