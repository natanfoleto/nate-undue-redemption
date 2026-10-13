class_name SporeMushroom
extends Node3D
## Cogumelo de esporos (08-mapa): quando Nate ou um mob passa perto, ele incha, com a marca no chão, e depois
## do aviso estoura numa nuvem que deixa lento quem está dentro, Nate ou mob. Volta a crescer depois de um tempo.

enum State { READY, SWELLING, CLOUD, REGROWING }

## A nuvem: círculo e aviso (a marca no chão). Não fere.
@export var attack: AttackData
## Distância que faz o cogumelo inchar, em blocos.
@export var trigger_radius := 0.0
## Quanto tempo a nuvem fica e em quanto tempo o cogumelo volta a crescer, em segundos.
@export var cloud_time := 0.0
@export var regrow_time := 0.0
## Tamanho do cogumelo inchado e do estourado, em relação ao normal.
@export var swell_scale := 1.0
@export var popped_scale := 1.0
## Cor e força do brilho do chapéu (10-arte-audio: fungos que brilham pelo próprio material).
@export var glow_color := Color.WHITE
@export var glow := 0.0

var state := State.READY
var _left := 0.0

@onready var _model: Node3D = $Model
@onready var _marker: WarningMarker = $WarningMarker
@onready var _cloud: CPUParticles3D = $Cloud


func _ready() -> void:
	_cloud.emitting = false
	for part in [&"cap", &"cap_top"]:
		(_model as BlockModel).set_part_glow(part, glow_color, glow)


func _physics_process(delta: float) -> void:
	_left -= delta
	match state:
		State.READY:
			if _someone_within(trigger_radius):
				state = State.SWELLING
				_left = attack.windup
				_marker.show_attack(attack, global_position, Vector3.FORWARD)
		State.SWELLING:
			var progress := clampf(1.0 - _left / attack.windup, 0.0, 1.0)
			_marker.set_progress(progress)
			_model.scale = Vector3.ONE * lerpf(1.0, swell_scale, progress)
			if _left <= 0.0:
				state = State.CLOUD
				_left = cloud_time
				_marker.hide_attack()
				_model.scale = Vector3.ONE * popped_scale
				_cloud.emitting = true
		State.CLOUD:
			_slow_inside()
			if _left <= 0.0:
				state = State.REGROWING
				_left = regrow_time
				_cloud.emitting = false
		State.REGROWING:
			_model.scale = Vector3.ONE * lerpf(1.0, popped_scale, clampf(_left / regrow_time, 0.0, 1.0))
			if _left <= 0.0:
				state = State.READY
				_model.scale = Vector3.ONE


# Lento enquanto está dentro e mais um pouco (11-balanceamento); com a Água, menos em Nate.
func _slow_inside() -> void:
	for faction: Hurtbox.Faction in [Hurtbox.Faction.PLAYER, Hurtbox.Faction.ENEMY]:
		for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(faction)):
			if not HitShape.overlaps(attack, global_position, Vector3.FORWARD, hurtbox.global_position, hurtbox.radius):
				continue
			if absf(hurtbox.global_position.y - global_position.y) > Balance.combat.height_reach:
				continue
			var status := hurtbox.receiver.get_node_or_null(^"StatusEffects") as StatusEffects
			if status:
				var share := Player.status_duration_share() if hurtbox.receiver is Player else 1.0
				status.apply(StatusEffects.Effect.SLOW, Balance.status.slow_linger, share)


func _someone_within(radius: float) -> bool:
	for faction: Hurtbox.Faction in [Hurtbox.Faction.PLAYER, Hurtbox.Faction.ENEMY]:
		for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(faction)):
			var offset := hurtbox.global_position - global_position
			if Vector2(offset.x, offset.z).length() <= radius + hurtbox.radius:
				return true
	return false
