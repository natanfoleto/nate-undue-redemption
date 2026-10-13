class_name SpellData
extends Resource
## Uma magia (05-itens): como sai, a área, o dano, o efeito e a recarga, com os números do 11-balanceamento.

## Projétil que explode ao parar; área que fere na hora; área que fica um tempo no chão; área que segue Nate.
enum Delivery { PROJECTILE, INSTANT, LASTING, AROUND }

## Chave do nome na tabela de tradução.
@export var name_key: StringName
@export var delivery := Delivery.INSTANT
## A área (e o projétil, quando há): forma, alcance, dano em pontos e recuo.
@export var attack: AttackData
## Explosão do projétil, onde ele para.
@export var explosion: AttackData
## Efeito de status em quem é atingido (-1 para nenhum) e por quanto tempo, em segundos; a queimadura usa a
## duração das regras de status.
@export var effect := -1
@export var effect_duration := 0.0
## Recarga, em segundos (só nas magias de elemento; a combinação usa as recargas das duas).
@export var cooldown := 0.0
## Quanto tempo a área fica no chão, em segundos.
@export var lasting := 0.0
## Distância da frente de Nate até o centro da área, em blocos.
@export var offset := 0.0
## Cor do efeito visual (10-arte-audio).
@export var color := Color.WHITE
## Modelo do projétil em voo.
@export var projectile_model: ModelData
