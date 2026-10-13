class_name RangedWeaponData
extends ItemData
## Arma à distância (05-itens): puxar até a força total e soltar, sem munição. Números do 11-balanceamento.

## Dano, em pontos.
@export var damage := 0
## Tempo para puxar até a força total, em segundos.
@export var draw_time := 0.0
## Alcance, em blocos.
@export var reach := 0.0
## Velocidade do projétil, em blocos/s.
@export var projectile_speed := 0.0
@export var knockback := AttackData.Knockback.NONE
## Efeito de status em quem é acertado (-1 para nenhum) e por quanto tempo, em segundos (Zarabatana marajoara).
@export var effect := -1
@export var effect_duration := 0.0
## Modelo do projétil em voo.
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
