class_name HintData
extends Resource
## Uma dica de controle (09-interface): as ações que ela ensina e o nome na tabela de tradução.

## Ações da dica, na ordem dos ícones; usar qualquer uma delas tira a dica.
@export var actions: Array[StringName] = []
## Chave do nome da ação na tabela de tradução.
@export var text_key: StringName
## Só sai quando todas as ações são apertadas juntas (a combinação).
@export var together := false
## Só sai quando o jogo avisa que a ação foi feita, e não pelo botão, que também serve para outra coisa (beber a
## poção: segurar o botão direito também atira).
@export var manual := false
