class_name AttackData
extends Resource
## Um golpe (03-regras): área, tempos, dano, recuo e aviso. Os números vêm do 11-balanceamento.
## As áreas ficam no plano do chão, saindo de quem golpeia na direção do golpe.

enum Shape { CIRCLE, SECTOR, RECTANGLE, PROJECTILE }
enum Knockback { NONE, SHORT, LONG }
## Golpe comum: pose, brilho e som. Golpe forte ou de área: marca no chão igual à área.
enum Warning { POSE, GROUND_MARK }

## Dano em pontos, contra os inimigos (golpes de Nate e armadilhas).
@export var damage_points := 0
## Dano em Nate, em pontos de vida (03-regras).
@export var player_damage := 0
@export var shape := Shape.CIRCLE
## Raio do círculo ou do setor, comprimento do retângulo ou alcance do projétil, em blocos.
@export var reach := 0.0
## Abertura total do setor, em graus.
@export var angle := 0.0
## Largura do retângulo, em blocos.
@export var width := 0.0
## Velocidade do projétil, em blocos/s.
@export var projectile_speed := 0.0
## Preparação (o aviso), em segundos.
@export var windup := 0.0
## Tempo ativo, em que o golpe fere, em segundos.
@export var active := 0.0
## Recuperação, em segundos.
@export var recovery := 0.0
## Recarga, em segundos, contada do fim do golpe.
@export var cooldown := 0.0
@export var knockback := Knockback.NONE
@export var warning := Warning.POSE
## Quanto quem golpeia avança durante o tempo ativo, em blocos (o salto do lobo).
@export var lunge := 0.0
## Efeito de status em quem é acertado (-1 para nenhum) e por quanto tempo, em segundos (o abalo do Golem).
@export var effect := -1
@export var effect_duration := 0.0
## Passa por paredes e pilares: os golpes da Boiúna, que vêm do alto e de todo lado (a marca no chão é sempre a área
## atingida).
@export var ignores_walls := false
## Sons do banco (data/audio/sounds.tres): o aviso, no começo da preparação, e o do golpe, quando ele sai.
@export var warning_sound: StringName
@export var strike_sound: StringName


## Duração do golpe inteiro, em segundos.
func total_time() -> float:
	return windup + active + recovery
