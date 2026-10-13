class_name RangedWeaponData
extends Resource
## Arma à distância (05-itens): puxar até a força total e soltar, sem munição. Números do 11-balanceamento.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Dano, em pontos.
@export var damage := 0
## Tempo para puxar até a força total, em segundos.
@export var draw_time := 0.0
## Alcance, em blocos.
@export var reach := 0.0
## Velocidade do projétil, em blocos/s.
@export var projectile_speed := 0.0
@export var knockback := AttackData.Knockback.NONE
## Modelo da arma na mão de Nate e do projétil em voo.
@export var model: ModelData
@export var projectile_model: ModelData


## O golpe do projétil.
func shot() -> AttackData:
	var attack := AttackData.new()
	attack.shape = AttackData.Shape.PROJECTILE
	attack.damage_points = damage
	attack.reach = reach
	attack.projectile_speed = projectile_speed
	attack.knockback = knockback
	return attack
