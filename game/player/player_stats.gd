class_name PlayerStats
extends Resource
## Números de Nate (11-balanceamento). O arquivo de dados fica em game/data/balance/.

## Velocidade de andar, em blocos/s.
@export var move_speed := 0.0
## Tempo para chegar à velocidade e para parar, em segundos.
@export var acceleration_time := 0.0
## Abertura total do cone da ajuda de mira, em graus.
@export var aim_assist_angle := 0.0
## Alcance da ajuda de mira, em blocos.
@export var aim_assist_range := 0.0
## Distância do rolamento, em blocos.
@export var roll_distance := 0.0
## Duração do rolamento, em segundos. Nate fica invencível o tempo todo.
@export var roll_duration := 0.0
## Recarga do rolamento, em segundos, contada do fim dele.
@export var roll_cooldown := 0.0
