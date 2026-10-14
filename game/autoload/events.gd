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
## Nate viu um mural de perto (a dica do botão dos murais).
signal mural_seen(mural_id: int)
## Nate bebeu a poção até o fim (a dica de beber).
signal flask_drunk
## Tremor da tela (as magias fortes): quanto, em blocos, e por quanto tempo, em segundos.
signal screen_shake(strength: float, seconds: float)
