class_name HintData
extends Resource
## Uma dica de controle (09-interface): as ações que ela ensina e o nome na tabela de tradução.

## Ações da dica, na ordem dos ícones; usar qualquer uma delas tira a dica.
@export var actions: Array[StringName] = []
## Chave do nome da ação na tabela de tradução.
@export var text_key: StringName
