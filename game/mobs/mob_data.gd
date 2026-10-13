class_name MobData
extends Resource
## Um tipo de mob (06-mobs): números do 11-balanceamento, o golpe, o modelo e as animações.

## Vida, em pontos.
@export var health := 0
## Velocidade de movimento, em blocos/s.
@export var move_speed := 0.0
## Distância em que nota Nate, em blocos.
@export var perception := 0.0
@export var weight := CombatRules.Weight.LIGHT
## Raio do círculo em que recebe golpes, em blocos.
@export var hurt_radius := 0.0
## Distância em que espera a vez de atacar, cercando Nate, em blocos.
@export var wait_distance := 0.0
@export var attack: AttackData

@export_group("Modelo")
@export var model: ModelData
## Tamanho do modelo: a variante maior usa o mesmo modelo, ampliado.
@export var model_scale := 1.0

@export_group("Animações")
@export var idle_animation: AnimationData
@export var walk_animation: AnimationData
## Pose de aviso, durante a preparação do golpe.
@export var windup_animation: AnimationData
## O golpe, durante o tempo ativo.
@export var attack_animation: AnimationData
@export var hurt_animation: AnimationData
@export var death_animation: AnimationData
