class_name EffectLook
extends Resource
## Aparência das partículas blocadas das magias e do cenário (10-arte-audio): estouro, onda e nuvem. Os tamanhos
## das áreas vêm de cada magia; aqui ficam quantidade, duração e velocidade. O arquivo fica em game/data/effects/.

## Lado de cada cubinho, em pixels (16 px = 1 bloco).
@export var cube_pixels := 0

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

@export_group("Onda")
## Transparência da onda no começo, de 0 a 1.
@export var wave_alpha := 0.0
## Altura e espessura da onda, em blocos e em parte da largura.
@export var wave_height := 0.0
@export var wave_thickness := 0.0
## Altura da onda sobre o chão, em blocos.
@export var wave_lift := 0.0

@export_group("Nuvem")
@export var cloud_amount := 0
## Duração de cada cubinho, em segundos.
@export var cloud_lifetime := 0.0
## Subida dos cubinhos, em blocos/s², e velocidade, menor e maior, em blocos/s.
@export var cloud_rise := 0.0
@export var cloud_speed := Vector2.ZERO
## Altura da nuvem sobre o chão, em blocos.
@export var cloud_lift := 0.0
