class_name SoundData
extends Resource
## Um som do jogo (10-arte-audio): uma ou mais gravações, uma sorteada a cada vez, com volume e variação de tom.

## As gravações; cada vez toca uma delas, sorteada.
@export var streams: Array[AudioStream] = []
## Volume, em decibéis.
@export var volume_db := 0.0
## Tom base (1 é o da gravação) e quanto ele varia para cima e para baixo a cada vez (0,1 = 10%).
@export var pitch := 1.0
@export var pitch_variation := 0.0
## Canal da mixagem: Effects, ou Warnings para os avisos de golpe, que ficam acima da música.
@export var bus := &"Effects"
