class_name MeleeWeaponData
extends Resource
## Arma corpo a corpo (05-itens): o combo de 3 golpes com os números do 11-balanceamento.
## O tempo de cada golpe se divide em preparação, tempo ativo e recuperação pela regra de combate.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Dano do 1º e do 2º golpe, em pontos.
@export var damage := 0
## Dano do 3º golpe, em pontos.
@export var damage_third := 0
## Tempo de cada golpe, em segundos.
@export var time_per_hit := 0.0
## Alcance, em blocos, e abertura do setor, em graus.
@export var reach := 0.0
@export var angle := 0.0
## Modelo da arma na mão de Nate.
@export var model: ModelData


## O golpe [param index] do combo (0, 1 ou 2).
func combo_hit(index: int, rules: CombatRules) -> AttackData:
	var attack := AttackData.new()
	attack.shape = AttackData.Shape.SECTOR
	attack.reach = reach
	attack.angle = angle
	attack.damage_points = damage_third if index == rules.combo_knockbacks.size() - 1 else damage
	attack.knockback = rules.combo_knockbacks[index]
	attack.windup = time_per_hit * rules.melee_windup_share
	attack.active = time_per_hit * rules.melee_active_share
	attack.recovery = time_per_hit * rules.melee_recovery_share
	return attack
