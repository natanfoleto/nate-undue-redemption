class_name AudioRules
extends Resource
## Números da mixagem e as músicas que valem para o jogo todo (10-arte-audio, 11-balanceamento).

## Volume da música e do som de fundo, em decibéis, e o tempo da troca de música, em segundos.
@export var music_volume_db := 0.0
@export var ambience_volume_db := 0.0
@export var fade_time := 0.0
## O volume em que a música some na troca, em decibéis.
@export var silent_db := 0.0
## Passos de Nate: um a cada tantos blocos andados.
@export var step_distance := 0.0
## Sons do mundo: distância em que tocam no volume cheio e a distância máxima em que ainda tocam, em blocos.
@export var unit_size := 0.0
@export var max_distance := 0.0
## Quantos sons podem tocar ao mesmo tempo: os do mundo e os da tela.
@export var world_voices := 0
@export var screen_voices := 0
## Músicas de fora das áreas: o tema do menu, a das arenas e a das memórias.
@export var menu_music: AudioStream
@export var arena_music: AudioStream
@export var memory_music: AudioStream
