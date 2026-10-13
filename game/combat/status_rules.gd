class_name StatusRules
extends Resource
## Números dos efeitos de status (03-regras, 11-balanceamento). O arquivo de dados fica em game/data/balance/.

## Parte da velocidade de quem está lento.
@export var slow_speed_share := 0.0
## Tempo a mais de lentidão depois de sair de uma área que deixa lento, em segundos.
@export var slow_linger := 0.0
## Tempo até o veneno agir, em segundos, e a vida que ele tira de Nate, em pontos.
@export var poison_delay := 0.0
@export var poison_damage := 0
## Queimadura: pontos a cada tique, tempo entre tiques e duração, em segundos.
@export var burn_damage := 0
@export var burn_interval := 0.0
@export var burn_duration := 0.0
## Parte da duração dos efeitos em Nate quando ele tem a Água equipada.
@export var water_duration_share := 0.0
