class_name FloorSpears
extends Node3D
## Lanças do chão (08-mapa): uma placa de pedra de onde lanças saem em ciclo fixo: recolhidas, aviso (o chão
## brilha, com a marca no chão) e para fora. Ferem quem estiver sobre a placa quando saem, Nate ou mob.

enum Phase { DOWN, WARNING, UP }

## O golpe da placa: retângulo do tamanho dela, dano em corações (Nate) e em pontos (mobs), recuo; o aviso é a
## preparação.
@export var attack: AttackData
## Tempo das lanças recolhidas e para fora, em segundos.
@export var down_time := 0.0
@export var up_time := 0.0
## Atraso no ciclo, em segundos: placas vizinhas sobem em ritmos diferentes.
@export var phase_offset := 0.0
## Profundidade das lanças recolhidas, em blocos, e o tempo para subir e descer, em segundos.
@export var hidden_depth := 0.0
@export var move_time := 0.0
## Cor e força do brilho da placa no aviso.
@export var glow_color := Color.WHITE
@export var glow := 0.0

var phase := Phase.DOWN
var _time := 0.0
var _already_hit: Array[Node3D] = []

@onready var _plate: BlockModel = $Plate
@onready var _spears: Node3D = $Spears
@onready var _marker: WarningMarker = $WarningMarker


func _ready() -> void:
	_spears.position.y = -hidden_depth
	_time = phase_offset


func _physics_process(delta: float) -> void:
	var cycle := down_time + attack.windup + up_time
	_time = fmod(_time + delta, cycle)
	var next := Phase.DOWN
	if _time >= down_time + attack.windup:
		next = Phase.UP
	elif _time >= down_time:
		next = Phase.WARNING
	if next != phase:
		_enter(next)
	if phase == Phase.WARNING:
		var progress := clampf((_time - down_time) / attack.windup, 0.0, 1.0)
		_marker.set_progress(progress)
		_plate.set_glow(progress * glow, glow_color)
	elif phase == Phase.UP:
		# Quem pisa na placa enquanto as lanças estão para fora também é ferido, uma vez por ciclo.
		for faction: Hurtbox.Faction in [Hurtbox.Faction.PLAYER, Hurtbox.Faction.ENEMY]:
			Strike.hit_area(attack, self, _area_origin(), -global_basis.z, faction, _already_hit, _build_hit)


func _enter(next: Phase) -> void:
	phase = next
	match next:
		Phase.WARNING:
			_marker.show_attack(attack, _area_origin(), -global_basis.z)
			AudioManager.play(attack.warning_sound, global_position)
		Phase.UP:
			_marker.hide_attack()
			AudioManager.play(attack.strike_sound, global_position)
			_plate.set_glow(0.0)
			_already_hit.clear()
			create_tween().tween_property(_spears, ^"position:y", 0.0, move_time)
		Phase.DOWN:
			create_tween().tween_property(_spears, ^"position:y", -hidden_depth, move_time)


# O retângulo da placa começa na borda de trás e vai para a frente (−z), do tamanho do golpe.
func _area_origin() -> Vector3:
	return global_position + global_basis.z * attack.reach / 2.0


func _build_hit(receiver: Node3D) -> Hit:
	var hit := Hit.new()
	hit.attacker = self
	hit.player_damage = attack.player_damage
	hit.points = attack.damage_points
	hit.knockback = attack.knockback
	var away := receiver.global_position - global_position
	away.y = 0.0
	hit.direction = away.normalized() if not away.is_zero_approx() else -global_basis.z
	return hit
