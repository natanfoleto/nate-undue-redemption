class_name Hit
extends RefCounted
## Um golpe que acertou alguém: quanto fere, para onde empurra e quem bateu.

## Quem bateu.
var attacker: Node3D
## Para onde o golpe empurra, no chão, de tamanho 1.
var direction := Vector3.ZERO
var knockback := AttackData.Knockback.NONE
## Dano em pontos, contra os inimigos.
var points := 0
## Dano em pontos de vida, contra Nate.
var player_damage := 0
var critical := false
## Efeito de status que o golpe aplica (-1 para nenhum) e por quanto tempo, em segundos.
var effect := -1
var effect_duration := 0.0
