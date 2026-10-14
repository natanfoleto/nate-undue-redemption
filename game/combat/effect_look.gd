class_name EffectLook
extends Resource
## Aparência do estouro de partículas blocadas do cenário (10-arte-audio: a poeira das paredes rachadas e do
## elevador) e a pausa curta no acerto das magias, que têm o visual próprio em SpellLook. O tamanho do estouro vem de
## quem o pede; aqui ficam quantidade, duração e velocidade. O arquivo fica em game/data/effects/.

## Lado de cada cubinho, em pixels (16 px = 1 bloco).
@export var cube_pixels := 0
## Na pausa curta do acerto das magias, quanto o tempo do jogo anda (0,05 é quase parado).
@export var hit_stop_scale := 1.0

@export_group("Estouro")
@export var burst_amount := 0
## Duração, em segundos.
@export var burst_lifetime := 0.0
## Velocidade dos cubinhos, menor e maior, em vezes o raio da área por segundo.
@export var burst_speed := Vector2.ZERO
## Alcance do clarão, em vezes o raio da área.
@export var flash_range := 0.0
## Altura do estouro sobre o chão, em blocos.
@export var burst_lift := 0.0
