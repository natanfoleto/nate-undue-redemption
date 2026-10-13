class_name CombatRules
extends Resource
## Regras de combate (03-regras), com os números do 11-balanceamento. O arquivo de dados fica em game/data/balance/.

## Peso de quem leva o golpe: decide o que o recuo faz com ele.
enum Weight { LIGHT, HEAVY, BOSS }

## Recuo curto, em blocos.
@export var short_knockback := 0.0
## Recuo longo, em blocos.
@export var long_knockback := 0.0
## Tempo que o empurrão leva para andar a distância do recuo, em segundos.
@export var knockback_time := 0.0
## Tempo sem agir de quem é interrompido, em segundos.
@export var interrupt_time := 0.0
## Menor e maior variação aleatória do dano de Nate.
@export var damage_variation_min := 0.0
@export var damage_variation_max := 0.0
## Quanto o crítico multiplica o dano.
@export var critical_multiplier := 0.0
## Quantos mobs podem preparar ataque contra Nate ao mesmo tempo.
@export var max_attackers := 0
## Tempo sem ver Nate até o mob desistir e voltar para casa, em segundos.
@export var give_up_time := 0.0
## Diferença de altura até onde um golpe ainda acerta, em blocos: mais que isso, o alvo está em outro nível do
## relevo (em cima ou embaixo de uma escada).
@export var height_reach := 0.0
## Parte do tempo de cada golpe de Nate gasta em preparação, tempo ativo e recuperação (somam 1).
@export var melee_windup_share := 0.0
@export var melee_active_share := 0.0
@export var melee_recovery_share := 0.0
## Recuo de cada golpe do combo de Nate, em ordem (04-player).
@export var combo_knockbacks: Array[AttackData.Knockback] = []


## Distância do empurrão, em blocos.
func knockback_distance(kind: AttackData.Knockback) -> float:
	match kind:
		AttackData.Knockback.SHORT:
			return short_knockback
		AttackData.Knockback.LONG:
			return long_knockback
		_:
			return 0.0


## Se o recuo empurra e interrompe quem tem esse peso: leve, qualquer recuo; pesado, só o longo; chefe, nenhum.
static func knockback_affects(weight: Weight, kind: AttackData.Knockback) -> bool:
	match weight:
		Weight.LIGHT:
			return kind != AttackData.Knockback.NONE
		Weight.HEAVY:
			return kind == AttackData.Knockback.LONG
		_:
			return false
