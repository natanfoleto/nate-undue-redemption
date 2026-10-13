class_name ArmorData
extends Resource
## Armadura (05-itens): corações extras e a velocidade de Nate; não reduz dano. Números do 11-balanceamento.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Corações a mais.
@export var extra_hearts := 0
## Velocidade de Nate com ela, em blocos/s.
@export var move_speed := 0.0
## Blocos sobre o corpo de Nate.
@export var model: ModelData
