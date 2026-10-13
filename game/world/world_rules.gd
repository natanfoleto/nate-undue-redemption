class_name WorldRules
extends Resource
## Números do mundo (11-balanceamento). O arquivo de dados fica em
## game/data/balance/.

## Tempo da tela escurecendo e clareando na troca de área, na viagem rápida e no descanso, em segundos.
@export var area_fade_time := 0.0
## Gravidade de quem anda (Nate, mobs e bichos), em blocos/s²: desce escadas e cai de beiradas.
@export var gravity := 0.0
