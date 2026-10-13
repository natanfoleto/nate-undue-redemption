class_name ArmorData
extends ItemData
## Armadura (05-itens): vida extra e a velocidade de Nate; não reduz dano. Números do 11-balanceamento.

## Vida a mais, em pontos.
@export var extra_health := 0
## Velocidade de Nate com ela, em blocos/s.
@export var move_speed := 0.0
## Recarga do dash com ela, em segundos; 0 mantém a de Nate (Manto de fibras marajoara).
@export var dash_cooldown := 0.0
## Bônus de dano, de 0 a 1 (Couraça de cerâmica marajoara: 15% a mais).
@export var damage_bonus := 0.0
