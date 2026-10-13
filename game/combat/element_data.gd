class_name ElementData
extends Resource
## Um elemento (05-itens): ensinado por um pergaminho, dá uma magia. O identificador é o nome do arquivo em
## game/data/elements/.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Ícone de 16 × 16 (09-interface).
@export var icon: Texture2D
## Desenho do elemento no pergaminho aberto (10-arte-audio).
@export var drawing: Texture2D
@export var spell: SpellData
