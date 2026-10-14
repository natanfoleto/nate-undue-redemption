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
## Distância do dash, em blocos.
@export var dash_distance := 0.0
## Duração do dash, em segundos. Nate fica invencível o tempo todo.
@export var dash_duration := 0.0
## Recarga do dash, em segundos, contada do fim dele.
@export var dash_cooldown := 0.0
## Golpe do dash: apertar atacar até este tempo antes do dash também conta (Espaço + clique em qualquer ordem), em
## segundos.
@export var dash_strike_window := 0.0

@export_group("Combate")
## Vida no começo do jogo, em pontos.
@export var max_health := 0
## Vida a mais por melhoria de vida, em pontos.
@export var upgrade_health := 0
## Chance de crítico, de 0 a 1.
@export var critical_chance := 0.0
## Raio do círculo em que Nate recebe golpes, em blocos.
@export var hurt_radius := 0.0
## Parte da velocidade com que Nate anda enquanto golpeia de perto.
@export var melee_speed_share := 0.0
## Tempo para continuar o combo depois da recuperação de um golpe, em segundos.
@export var combo_window := 0.0
## Recuperação depois do tiro, em segundos.
@export var shot_recovery := 0.0
## Parte da velocidade com que Nate anda enquanto puxa o tiro.
@export var drawing_speed_share := 0.0
## Tempo sem controle a cada golpe levado, em segundos.
@export var hit_stun := 0.0
## Tempo invencível depois de levar golpe, em segundos.
@export var hit_invincibility := 0.0
## Intervalo do piscar enquanto está invencível depois de levar golpe, em segundos.
@export var blink_interval := 0.0
## Tempo da tela escurecendo depois da morte, até Nate voltar, em segundos.
@export var death_time := 0.0
## Tempo da tela clareando quando Nate volta, em segundos.
@export var respawn_fade_time := 0.0

@export_group("Vida")
## Tempo sem levar dano até a vida começar a voltar, em segundos. Só volta fora de combate.
@export var regen_delay := 0.0
## Vida que volta, em pontos por segundo.
@export var regen_rate := 0.0

@export_group("Frasco")
## Cargas do frasco sem melhorias.
@export var flask_charges := 0
## Vida curada por carga, em pontos.
@export var flask_heal := 0
## Tempo para beber, em segundos.
@export var flask_time := 0.0
## Parte da velocidade com que Nate anda enquanto bebe.
@export var flask_speed_share := 0.0

@export_group("Muiraquitã")
## Raio da Luz Ancestral, em blocos.
@export var light_radius := 0.0
