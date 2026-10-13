class_name NecromancerData
extends MobData
## O Necromante (06-mobs/necromante.md): a praga à distância, a invocação de esqueletos e a distância que ele
## mantém de Nate. O golpe base (attack) é a praga.

## Quantas pragas saem de cada vez e a abertura total do leque, em graus (o Ancião lança 3).
@export var plague_count := 1
@export var plague_fan_angle := 0.0
## Efeito da praga e por quanto tempo, em segundos.
@export var plague_effect := -1
@export var plague_effect_duration := 0.0
## Altura de onde sai a praga, em blocos: a da pedra do cajado erguido.
@export var plague_height := 0.0
## Modelo da praga em voo, e a cor e a força do brilho dela.
@export var plague_model: ModelData
@export var plague_color := Color.WHITE
@export var plague_glow := 0.0
## Recua quando Nate chega mais perto que isto, em blocos.
@export var retreat_distance := 0.0

@export_group("Invocar")
## Tempos e recarga da invocação; a área é o círculo da marca onde cada esqueleto surge.
@export var summon: AttackData
@export var summon_scene: PackedScene
## Quantos surgem de cada vez e quantos invocados podem estar vivos ao mesmo tempo.
@export var summon_count := 0
@export var summon_max := 0
## Distância do Necromante até cada marca de invocação, em blocos.
@export var summon_distance := 0.0
@export var summon_animation: AnimationData
