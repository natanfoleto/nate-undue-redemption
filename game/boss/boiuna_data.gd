class_name BoiunaData
extends Resource
## A Boiúna (07-chefes/boiuna): os números do 11-balanceamento, os golpes, o modelo e as cores. O arquivo de dados
## fica em game/data/boss/.

@export_group("Vida")
## Vida de cada parte da fase 1, em pontos, e quantas partes ela tem.
@export var part_health := 0
@export var parts := 0
## Tempo atordoada depois de cada parte derrubada, em segundos.
@export var stun_time := 0.0
## Vida da fase 2, em pontos.
@export var phase_2_health := 0

@export_group("Pilares")
## Tempo segurando interagir para ativar um pilar, em segundos.
@export var pillar_hold_time := 0.0
## Espera entre um ataque e outro na fase 1, com 0, 1, 2 e 3 pilares ativos, em segundos.
@export var intervals: Array[float] = []

@export_group("Golpes")
## Fase 1: o bote (a recuperação é a cabeça no chão), a varrida de cauda e o cuspe de escuridão.
@export var bite: AttackData
@export var tail_sweep: AttackData
@export var spit: AttackData
## Fase 2: a emboscada (a recuperação é a cabeça exposta) e o cerco.
@export var ambush: AttackData
@export var ring: AttackData
## Na fase 2, um ataque começa a cada tantos segundos, contados do começo do anterior.
@export var ambush_every := 0.0
## A ordem dos ataques da fase 2, repetida: verdadeiro é cerco; falso, emboscada.
@export var phase_2_rings: Array[bool] = []
## Quanto o bote e a emboscada passam do ponto onde Nate estava, em blocos (a cabeça cai em cima dele).
@export var lunge_overshoot := 0.0
## O cuspe: quantos círculos, a distância dos outros até o de Nate, em blocos, o tempo do voo até o chão e o das
## poças, em segundos.
@export var spit_count := 0
@export var spit_spread := 0.0
@export var spit_flight := 0.0
@export var pool_time := 0.0
## Tempo para a poça sumir no fim, em segundos.
@export var pool_fade_time := 0.0

@export_group("Corpo")
## Círculo em que o corpo recebe golpes, em volta do fosso, e o da cabeça, em blocos.
@export var body_hurt_radius := 0.0
@export var head_hurt_radius := 0.0
## Tamanho do modelo: a cabeça e os gomos, ampliados.
@export var model_scale := 1.0
## A cabeça parada: a altura dela e quanto ela se inclina do centro do fosso para o lado de Nate, em blocos.
@export var head_height := 0.0
@export var head_reach := 0.0
## Altura da cabeça deitada no chão (no bote, na emboscada e atordoada), em blocos.
@export var head_rest_height := 0.0
## Tempos de sair do fosso, de voltar para ele e de a cabeça voltar ao lugar depois de um golpe, em segundos.
@export var emerge_time := 0.0
@export var dive_time := 0.0
@export var head_return_time := 0.0
## Distância entre um gomo e o próximo, em tamanhos de gomo, e a fundura de onde o corpo sai, em blocos.
@export var segment_spacing := 0.0
@export var depth := 0.0
## O comprimento da cauda na varrida, deitada no chão, e a altura da ponta dela erguida, em blocos.
@export var tail_length := 0.0
@export var tail_height := 0.0

## Quão depressa a cabeça segue o lugar dela (por segundo), fora dos botes, que são exatos.
@export var head_follow := 0.0
## Antes do bote e do cuspe, a cabeça recua e sobe, em blocos; a garganta incha (em vezes o tamanho) e a boca abre
## até este ângulo, em graus.
@export var coil_back := 0.0
@export var coil_rise := 0.0
@export var throat_swell := 0.0
@export var jaw_open := 0.0
## A cena da troca de fase: quanto a cabeça balança no alto, em blocos, e o tempo de uma volta, em segundos.
@export var thrash_sway := 0.0
@export var thrash_time := 0.0
## O balanço da cabeça parada: quanto, em blocos, e o tempo de uma volta, em segundos.
@export var sway := 0.0
@export var sway_time := 0.0
## O cerco: a cabeça dá tantas voltas em Nate enquanto o anel fecha, e o anel fecha até este raio, em blocos.
@export var ring_turns := 0.0
@export var ring_closed_radius := 0.0
## Na fase 2, o primeiro ataque vem depois deste tempo, em segundos.
@export var phase_2_first_delay := 0.0

@export_group("Visual")
## A cabeça e o gomo do corpo, que o jogo repete numa fila (a cauda usa o mesmo gomo, mais fino).
@export var head_model: ModelData
@export var segment_model: ModelData
## Grossura do corpo e da cauda, do fosso à ponta, em tamanhos de gomo.
@export var body_thickness := Vector2.ONE
@export var tail_thickness := Vector2.ONE
## Quanto a cabeça se inclina para olhar Nate lá embaixo (0 reto, 1 direto para ele) e quanto a boca fica aberta
## atordoada (1 é toda aberta).
@export var look_pitch := 0.0
@export var stunned_jaw := 0.0
## Cor e força do brilho dos olhos: parada, avisando um golpe e atordoada.
@export var eye_color := Color.WHITE
@export var eye_glow := 0.0
@export var eye_warning_glow := 0.0
@export var eye_stunned_glow := 0.0
## Clarão branco ao levar golpe, em segundos, e o tempo mínimo entre dois sinais de imune.
@export var hurt_flash_time := 0.0
@export var immune_wait := 0.0
## Na frente de Nate, ela fica com esta opacidade (0 some, 1 inteira), mudando neste tempo, em segundos; conta a
## altura do peito dele e uma folga em volta, em blocos.
@export var see_through_alpha := 1.0
@export var see_through_time := 0.0
@export var see_through_height := 0.0
@export var see_through_margin := 0.0
## Cor das poças e do cuspe, e o tamanho de cada gota do cuspe, em blocos.
@export var pool_color := Color.WHITE
@export var spit_size := 0.0
## Quanto o voo do cuspe sobe no meio do caminho, em blocos, e quantas voltas cada gota dá no voo (em dois eixos).
@export var spit_arc := 0.0
@export var spit_turns := Vector2.ZERO
## O respingo de escuridão ao sair do fosso e ao mergulhar, e o raio dele, em blocos.
@export var splash_look: EffectLook
@export var splash_radius := 0.0
## Tremor da tela quando a cabeça ou a cauda batem no chão, e quando ela ruge: quanto, em blocos, e por quanto
## tempo, em segundos.
@export var slam_shake := 0.0
@export var slam_shake_time := 0.0
@export var roar_shake := 0.0
@export var roar_shake_time := 0.0
