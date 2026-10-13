extends Node
## Canal de sinais entre os sistemas; o salvamento ouve os sinais de conquista (12-tecnico).

## Nate caiu; a tela escurece antes de ele voltar.
signal player_died
## Nate voltou ao ponto de retorno: os inimigos vivos reiniciam, com vida cheia e na posição inicial (02-core-loop).
signal player_respawned
## Um inimigo morreu e continua morto.
signal enemy_died(enemy: Node3D)
## Nate pegou um item (do chão ou de um baú).
signal item_picked(item_id: StringName)
