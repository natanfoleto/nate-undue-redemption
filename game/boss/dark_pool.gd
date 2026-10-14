class_name DarkPool
extends MeshInstance3D
## Poça de escuridão do cuspe da Boiúna (07-chefes/boiuna): fica alguns segundos no chão e deixa lento quem pisa,
## enquanto estiver dentro e mais um pouco (11-balanceamento); depois some aos poucos.

var _attack: AttackData
var _left := 0.0
var _fade_time := 0.0
var _material: StandardMaterial3D


## Começa a poça com a forma de [param attack] (o círculo do cuspe), da cor dada, por [param seconds]; no fim, ela
## some em [param fade_time] segundos.
func start(attack: AttackData, color: Color, seconds: float, fade_time: float) -> void:
	_attack = attack
	_left = seconds
	_fade_time = fade_time
	mesh = AreaMesh.build(attack)
	_material = StandardMaterial3D.new()
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = color
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Some na hora (a luta recomeçando).
func clear() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		set_physics_process(false)
		var tween := create_tween()
		tween.tween_property(_material, ^"albedo_color:a", 0.0, _fade_time)
		tween.tween_callback(queue_free)
		return
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group(Hurtbox.group_for(Hurtbox.Faction.PLAYER)):
		if not HitShape.overlaps(_attack, global_position, Vector3.FORWARD, hurtbox.global_position, hurtbox.radius):
			continue
		if absf(hurtbox.global_position.y - global_position.y) > Balance.combat.height_reach:
			continue
		var status := hurtbox.receiver.get_node_or_null(^"StatusEffects") as StatusEffects
		if status:
			status.apply(StatusEffects.Effect.SLOW, Balance.status.slow_linger, Player.status_duration_share())
