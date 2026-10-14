class_name SpellLook
extends Resource
## O visual de uma magia (10-arte-audio): as camadas de partículas ao lançar (em Nate), no voo do projétil, no
## impacto e enquanto a área dura; a luz; a marca no chão, com a forma da área; o tremor da tela; e a pausa curta no
## acerto. Os números da magia (área, dano e tempos) ficam no SpellData.

@export var cast: Array[ParticleLayer] = []
@export var trail: Array[ParticleLayer] = []
@export var impact: Array[ParticleLayer] = []
@export var lasting: Array[ParticleLayer] = []
## Tempo para o impacto correr a área do começo ao fim (a Onda Cortante e o Magma), em segundos; 0 sai de uma vez.
@export var sweep_time := 0.0
## Luz do impacto (ou da área, enquanto ela dura): cor, força, alcance em partes do raio da área e o tempo até
## apagar, em segundos.
@export var light_color := Color.WHITE
@export var light_energy := 0.0
@export var light_range := 0.0
@export var light_time := 0.0
## Marca no chão, com a forma da área (queimado, gelo, rachaduras, lama): cor, tempo até sumir, em segundos, e se ela
## acende sozinha (a lava e o gelo).
@export var mark_color := Color.TRANSPARENT
@export var mark_time := 0.0
@export var mark_glows := false
## Tremor da tela, em blocos, e quanto ele dura, em segundos; pausa curta quando a magia acerta alguém, em segundos.
@export var shake := 0.0
@export var shake_time := 0.0
@export var hit_stop := 0.0
