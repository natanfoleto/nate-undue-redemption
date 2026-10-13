class_name ItemData
extends Resource
## O que todo item de equipamento tem (05-itens): nome, ícone, raridade e modelo.

## Chave do nome na tabela de tradução.
@export var name_key: StringName
## Ícone no inventário, de 16 × 16 pixels (09-interface).
@export var icon: Texture2D
## Feito pelo povo antigo: brilho e moldura verde-jade; comum: moldura cinza (10-arte-audio).
@export var marajoara := false
## Modelo do item: na mão de Nate, no corpo ou no chão.
@export var model: ModelData
